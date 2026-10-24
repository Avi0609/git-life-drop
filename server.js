const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const db = require('./db');
const donorsRouter = require('./routes/donors');
const searchRouter = require('./routes/search');
const centersRouter = require('./routes/centers');
const requestsRouter = require('./routes/requests');
const statsRouter = require('./routes/stats');
const reportsRouter = require('./routes/reports');
const campsRouter = require('./routes/camps');

const app = express();
const PORT = process.env.PORT || 5000;

// CORS & Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve frontend static files
app.use(express.static(path.join(__dirname)));
app.use('/css', express.static(path.join(__dirname, 'css')));
app.use('/js', express.static(path.join(__dirname, 'js')));
app.use('/images', express.static(path.join(__dirname, 'images')));

// REST API Endpoints
app.use('/api/donors', donorsRouter);
app.use('/api/search', searchRouter);
app.use('/api/centers', centersRouter);
app.use('/api/requests', requestsRouter);
app.use('/api/stats', statsRouter);
app.use('/api/reports', reportsRouter);
app.use('/api/camps', campsRouter);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    timestamp: new Date().toISOString(),
    database: db.type,
    coverage: ['Ranchi', 'Bokaro', 'Jamshedpur', 'Ramgarh', 'Deoghar', 'Hazaribagh']
  });
});

// Explicit route for homepage
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// 404 handler for API routes
app.use((req, res, next) => {
  if (req.path.startsWith('/api')) {
    return res.status(404).json({ success: false, error: 'API endpoint not found' });
  }
  next();
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err);
  res.status(500).json({ success: false, error: 'Internal Server Error' });
});

// Initialize database and start listening
async function startServer() {
  try {
    await db.initDb();
    app.listen(PORT, '0.0.0.0', () => {
      console.log('====================================================');
      console.log(`🩸 LifeDrop Blood Donation & Search Platform Running!`);
      console.log(`📡 Local Web & API:   http://localhost:${PORT}`);
      console.log(`🌐 Network URL:       http://127.0.0.1:${PORT}`);
      console.log(`🔍 Search API:        http://localhost:${PORT}/api/search`);
      console.log(`❤️  Donors API:        http://localhost:${PORT}/api/donors`);
      console.log(`🏥 Centers API:       http://localhost:${PORT}/api/centers`);
      console.log(`🚨 Requests API:      http://localhost:${PORT}/api/requests`);
      console.log(`🛡️  Fraud Reports API: http://localhost:${PORT}/api/reports`);
      console.log(`📊 Stats API:         http://localhost:${PORT}/api/stats`);
      console.log(`💾 Active Database:   ${db.type.toUpperCase()}`);
      console.log(`📍 Key Regional Hubs: Ranchi, Bokaro, Jamshedpur, Ramgarh, Deoghar, Hazaribagh`);
      console.log('====================================================');
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

startServer();

