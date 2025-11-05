require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
const path = require('path');
const mongoose = require('mongoose');

// Импорт конфигураций
const connectDB = require('./config/database');
const { initializeFirebase } = require('./config/firebase');

// Импорт middleware
const auth = require('./middleware/auth');

// Импорт маршрутов
const userRoutes = require('./routes/users');
const postRoutes = require('./routes/posts');
const groupRoutes = require('./routes/groups');
const advertisementRoutes = require('./routes/advertisements');
const eventRoutes = require('./routes/events');
const chatRoutes = require('./routes/chats');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Подключение к базе данных (с обработкой ошибок)
const startServer = async () => {
  try {
    await connectDB();
    console.log('✅ MongoDB connected successfully');
  } catch (error) {
    console.log('⚠️  MongoDB connection failed, running without database');
    console.log('   To fix this, make sure MongoDB is running or update MONGODB_URI in .env');
  }

  // Инициализация Firebase (с обработкой ошибок)
  try {
    initializeFirebase();
    console.log('✅ Firebase initialized successfully');
  } catch (error) {
    console.log('⚠️  Firebase initialization failed, running without Firebase');
    console.log('   To fix this, update Firebase credentials in .env');
  }

  // Middleware
  app.use(cors());
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true }));

  // Статические файлы
  app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

  // Маршруты API (только если база данных подключена)
  try {
    app.use('/api/users', userRoutes);
    app.use('/api/posts', postRoutes);
    app.use('/api/groups', groupRoutes);
    app.use('/api/advertisements', advertisementRoutes);
    app.use('/api/events', eventRoutes);
    app.use('/api/chats', chatRoutes);
    console.log('✅ API routes loaded successfully');
  } catch (error) {
    console.log('⚠️  API routes not loaded due to database connection issues');
  }

  // Тестовый маршрут
  app.get('/api/health', (req, res) => {
    res.json({
      success: true,
      message: 'Sosedi API is running',
      timestamp: new Date().toISOString(),
      database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
    });
  });

  // Обработка ошибок
  app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
      success: false,
      message: 'Something went wrong!',
    });
  });

  // Обработка 404
  app.use('*', (req, res) => {
    res.status(404).json({
      success: false,
      message: 'Route not found',
    });
  });

  // Socket.IO обработка
  const connectedUsers = new Map();

  io.on('connection', (socket) => {
    console.log('User connected:', socket.id);

    // Аутентификация пользователя
    socket.on('authenticate', async (token) => {
      try {
        // Здесь должна быть верификация токена
        // Пока просто сохраняем socket.id
        connectedUsers.set(socket.id, { socketId: socket.id });
        socket.emit('authenticated');
      } catch (error) {
        socket.emit('auth_error', { message: 'Authentication failed' });
      }
    });

    // Присоединение к чату
    socket.on('join_chat', (chatId) => {
      socket.join(`chat_${chatId}`);
      console.log(`User ${socket.id} joined chat ${chatId}`);
    });

    // Отправка сообщения
    socket.on('send_message', (data) => {
      const { chatId, message } = data;
      socket.to(`chat_${chatId}`).emit('new_message', {
        chatId,
        message,
        timestamp: new Date(),
      });
    });

    // Отключение пользователя
    socket.on('disconnect', () => {
      console.log('User disconnected:', socket.id);
      connectedUsers.delete(socket.id);
    });
  });

  const PORT = process.env.PORT || 3000;

  server.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`📡 Health check: http://localhost:${PORT}/api/health`);
  });
};

// Запускаем сервер
startServer().catch(console.error);

module.exports = { app, server, io }; 