require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { sequelize } = require('./models');

// Import routes
const authRoutes = require('./routes/authRoutes');
const postinganRoutes = require('./routes/postinganRoutes');
const komentarRoutes = require('./routes/komentarRoutes');
const interaksiRoutes = require('./routes/interaksiRoutes');
const penggunaRoutes = require('./routes/penggunaRoutes');
const kategoriRoutes = require('./routes/kategoriRoutes');
const notifikasiRoutes = require('./routes/notifikasiRoutes');

const app = express();

// Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// CORS configuration for production (Railway)
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);

    // Allow localhost for development and Railway domains for production
    const allowedOrigins = [
      /^http:\/\/localhost:\d+$/,
      /^http:\/\/127\.0\.0\.1:\d+$/,
      /^https:\/\/localhost:\d+$/,
      /^https:\/\/127\.0\.0\.1:\d+$/,
      /^https:\/\/.*\.railway\.app$/,
      /^https:\/\/.*\.up\.railway\.app$/
    ];

    const isAllowed = allowedOrigins.some(pattern => pattern.test(origin));
    if (isAllowed) {
      return callback(null, true);
    }

    console.log('CORS allowed origin:', origin);
    callback(null, true); // Allow all origins in production for now
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  optionsSuccessStatus: 200
}));

// Handle preflight OPTIONS requests
app.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', req.headers.origin || '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.header('Access-Control-Allow-Credentials', 'true');
  res.sendStatus(200);
});

// Request logging middleware
app.use((req, res, next) => {
  console.log(`📨 ${req.method} ${req.path} - Origin: ${req.headers.origin} - Body:`, req.body);
  next();
});

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    message: '🚀 API Platform Aspirasi Mahasiswa berjalan!',
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    database: 'connected',
    timestamp: new Date().toISOString()
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/postingan', postinganRoutes);
app.use('/api/komentar', komentarRoutes);
app.use('/api/interaksi', interaksiRoutes);
app.use('/api/pengguna', penggunaRoutes);
app.use('/api/kategori', kategoriRoutes);
app.use('/api/notifikasi', notifikasiRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.originalUrl} not found`
  });
});

// Database connection and synchronization
async function connectDatabase() {
  try {
    console.log('🔄 Connecting to database...');
    await sequelize.authenticate();
    console.log("✅ Database connected successfully");

    console.log('🔄 Synchronizing database...');
    await sequelize.sync(); 
    console.log("✅ Database synchronized");
  } catch (error) {
    console.error("❌ Error connecting to database:", error);
    process.exit(1);
  }
}

// Start server
async function startServer() {
  await connectDatabase();
  
  const PORT = process.env.PORT || 5000;
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`📡 Database: ${process.env.DATABASE_URL ? 'Railway PostgreSQL' : 'Local PostgreSQL'}`);
  });
}

startServer().catch(console.error);
