const fs = require('fs');
const path = require('path');
require('dotenv').config();

let DB_TYPE = (process.env.DB_TYPE || 'mysql').toLowerCase();

let activeClient = null;

function createSqliteClient() {
  const { DatabaseSync } = require('node:sqlite');
  const dbPath = process.env.SQLITE_PATH || path.join(__dirname, 'blood_donation.db');
  const db = new DatabaseSync(dbPath);

  return {
    type: 'sqlite',
    async query(sql, params = []) {
      const stmt = db.prepare(sql);
      return stmt.all(...params);
    },
    async get(sql, params = []) {
      const stmt = db.prepare(sql);
      return stmt.get(...params) || null;
    },
    async execute(sql, params = []) {
      const stmt = db.prepare(sql);
      const res = stmt.run(...params);
      return {
        affectedRows: res.changes,
        insertId: Number(res.lastInsertRowid)
      };
    },
    async initDb() {
      const check = db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='donors'").get();
      if (!check) {
        console.log('📦 Initializing SQLite database schema from schema.sql...');
        const schemaPath = path.join(__dirname, 'schema.sql');
        if (fs.existsSync(schemaPath)) {
          const sql = fs.readFileSync(schemaPath, 'utf8');
          db.exec(sql);
          console.log('✅ SQLite database initialized and seeded successfully.');
        }
      } else {
        // Ensure blood_camps table exists even if db was created previously
        const checkCamps = db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='blood_camps'").get();
        if (!checkCamps) {
          console.log('🏕️ Initializing blood_camps table in SQLite...');
          const schemaPath = path.join(__dirname, 'schema.sql');
          if (fs.existsSync(schemaPath)) {
            const sql = fs.readFileSync(schemaPath, 'utf8');
            db.exec(sql);
            console.log('✅ blood_camps table created and seeded.');
          }
        }
        console.log('💾 SQLite database ready. Existing tables detected.');
      }
    }
  };
}

function createMysqlClient() {
  const mysql = require('mysql2/promise');
  const dbHost = process.env.DB_HOST || 'localhost';
  const dbUser = process.env.DB_USER || 'root';
  const dbPassword = process.env.DB_PASSWORD || '';
  const dbName = process.env.DB_NAME || 'blood_donation';
  const dbPort = Number(process.env.DB_PORT) || 3306;

  let pool = null;

  function getPool() {
    if (!pool) {
      pool = mysql.createPool({
        host: dbHost,
        user: dbUser,
        password: dbPassword,
        database: dbName,
        port: dbPort,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0,
        multipleStatements: true
      });
    }
    return pool;
  }

  return {
    type: 'mysql',
    async query(sql, params = []) {
      const p = getPool();
      const [rows] = await p.query(sql, params);
      return rows;
    },
    async get(sql, params = []) {
      const p = getPool();
      const [rows] = await p.query(sql, params);
      return rows[0] || null;
    },
    async execute(sql, params = []) {
      const p = getPool();
      const [result] = await p.query(sql, params);
      return {
        affectedRows: result.affectedRows,
        insertId: result.insertId
      };
    },
    async initDb() {
      console.log(`🔌 Attempting MySQL connection to "${dbName}" at ${dbHost}:${dbPort}...`);

      try {
        const rootConn = await mysql.createConnection({
          host: dbHost,
          user: dbUser,
          password: dbPassword,
          port: dbPort,
          multipleStatements: true
        });

        await rootConn.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
        await rootConn.end();

        const p = getPool();
        const [tables] = await p.query(
          "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'donors'",
          [dbName]
        );

        if (tables.length === 0) {
          console.log(`📦 Database "${dbName}" has no tables. Initializing from schema_mysql.sql...`);
          const schemaPath = path.join(__dirname, 'schema_mysql.sql');
          if (fs.existsSync(schemaPath)) {
            const sql = fs.readFileSync(schemaPath, 'utf8');
            await p.query(sql);
            console.log(`✅ MySQL database "${dbName}" seeded with Jharkhand data successfully!`);
          }
        } else {
          console.log(`💾 MySQL database "${dbName}" ready. Tables verified.`);
        }
      } catch (err) {
        console.warn(`⚠️ MySQL is not reachable on ${dbHost}:${dbPort} (${err.code || err.message}).`);
        console.warn('🔄 Falling back to built-in SQLite engine so your server starts without interruption.');
        console.warn('👉 To activate MySQL: Start MySQL in XAMPP or Windows Service, then run: npm run setup:mysql\n');

        // Fallback to SQLite
        const sqlite = createSqliteClient();
        await sqlite.initDb();
        this.type = sqlite.type;
        this.query = sqlite.query;
        this.get = sqlite.get;
        this.execute = sqlite.execute;
      }
    }
  };
}

if (DB_TYPE === 'mysql') {
  activeClient = createMysqlClient();
} else {
  activeClient = createSqliteClient();
}

module.exports = activeClient;

