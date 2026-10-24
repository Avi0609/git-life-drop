/**
 * LIFE DROP - MYSQL SETUP & MIGRATION TOOL
 * Connects to MySQL, creates database `blood_donation`, executes schema_mysql.sql,
 * and sets up all Jharkhand hospitals, sectors, donors, and fraud tables.
 */

const fs = require('fs');
const path = require('path');
require('dotenv').config();

const mysql = require('mysql2/promise');

async function setupMySQL() {
  console.log('====================================================');
  console.log('🩸 LifeDrop - MySQL Database Setup & Migration Tool');
  console.log('   Target Regions: Ranchi, Bokaro, Jamshedpur, Ramgarh, Deoghar, Hazaribagh');
  console.log('====================================================');

  const host = process.env.DB_HOST || 'localhost';
  const port = Number(process.env.DB_PORT) || 3306;
  const user = process.env.DB_USER || 'root';
  const password = process.env.DB_PASSWORD || '';
  const database = process.env.DB_NAME || 'blood_donation';

  console.log(`Connecting with credentials:`);
  console.log(`  • Host:     ${host}`);
  console.log(`  • Port:     ${port}`);
  console.log(`  • User:     ${user}`);
  console.log(`  • Password: ${password ? '********' : '(None/Blank)'}`);
  console.log(`  • Database: ${database}`);
  console.log('----------------------------------------------------');

  let connection = null;

  try {
    console.log('⏳ Connecting to MySQL server...');
    connection = await mysql.createConnection({
      host,
      port,
      user,
      password,
      multipleStatements: true
    });
    console.log('✅ Connected to MySQL server successfully!');
  } catch (err) {
    console.error('❌ Connection failed!');
    console.error(`   Error Code: ${err.code}`);
    console.error(`   Message:    ${err.message}`);
    console.log('\n💡 Troubleshooting Tips:');
    console.log('   1. If using XAMPP: Click "Start" on MySQL in XAMPP Control Panel.');
    console.log('   2. If using MySQL Service / Workbench: Ensure MySQL Service is running.');
    console.log('   3. If you have a password, update DB_PASSWORD in .env file:');
    console.log('      DB_PASSWORD=your_password');
    console.log('   4. Verify DB_PORT in .env (usually 3306 or 3307).');
    process.exit(1);
  }

  try {
    // 1. Create database
    console.log(`⏳ Creating database \`${database}\` if not exists...`);
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
    console.log(`✅ Database \`${database}\` is ready.`);

    // 2. Select database
    await connection.query(`USE \`${database}\`;`);

    // 3. Read and execute schema_mysql.sql
    const schemaPath = path.join(__dirname, 'schema_mysql.sql');
    if (!fs.existsSync(schemaPath)) {
      throw new Error(`Schema file not found at ${schemaPath}`);
    }

    console.log(`⏳ Importing Jharkhand tables and seed data from schema_mysql.sql...`);
    const sql = fs.readFileSync(schemaPath, 'utf8');
    await connection.query(sql);
    console.log('✅ Tables created and seeded successfully!');

    // 4. Verify counts
    const [centers] = await connection.query('SELECT COUNT(*) as count FROM blood_centers');
    const [inventory] = await connection.query('SELECT COUNT(*) as count, SUM(units_available) as units FROM blood_inventory');
    const [donors] = await connection.query('SELECT COUNT(*) as count FROM donors');
    const [requests] = await connection.query('SELECT COUNT(*) as count FROM blood_requests');
    const [reports] = await connection.query('SELECT COUNT(*) as count FROM suspicious_reports');
    const [camps] = await connection.query('SELECT COUNT(*) as count FROM blood_camps');

    console.log('----------------------------------------------------');
    console.log('📊 Verification Summary:');
    console.log(`  • Certified Centers:    ${centers[0].count} centers (Ranchi, Bokaro, Jamshedpur, etc.)`);
    console.log(`  • Blood Inventory:      ${inventory[0].count} inventory rows (${inventory[0].units} units in stock)`);
    console.log(`  • Verified Donors:      ${donors[0].count} donors`);
    console.log(`  • Emergency Requests:   ${requests[0].count} patient requests`);
    console.log(`  • Suspicious Reports:   ${reports[0].count} initial fraud records`);
    console.log(`  • Upcoming Camps:       ${camps[0].count} donation drives in Jharkhand`);
    console.log('----------------------------------------------------');

    // 5. Update .env to activate DB_TYPE=mysql
    const envPath = path.join(__dirname, '.env');
    if (fs.existsSync(envPath)) {
      let envContent = fs.readFileSync(envPath, 'utf8');
      if (envContent.includes('DB_TYPE=sqlite')) {
        envContent = envContent.replace('DB_TYPE=sqlite', 'DB_TYPE=mysql');
        fs.writeFileSync(envPath, envContent, 'utf8');
      }
      console.log('✅ Verified .env: DB_TYPE=mysql');
    }

    console.log('\n🎉 SUCCESS! MySQL Database is fully initialized for LifeDrop Jharkhand.');
    console.log('You can now start the application: npm start or start-server.bat\n');
  } catch (err) {
    console.error('❌ Failed during schema import:');
    console.error(err.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

setupMySQL();

