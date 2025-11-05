const express = require('express');
const cors = require('cors');
const http = require('http');
const path = require('path');

const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Статические файлы
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Тестовый маршрут
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Sosedi API is running (Working Mode)',
    timestamp: new Date().toISOString(),
    database: 'not connected',
  });
});

// Простые тестовые маршруты
app.get('/api/test/users', (req, res) => {
  res.json({
    success: true,
    data: [
      {
        id: '1',
        firstName: 'Иван',
        lastName: 'Иванов',
        address: 'ул. Ленина, 1',
        phoneNumber: '+7 999 123-45-67'
      },
      {
        id: '2',
        firstName: 'Мария',
        lastName: 'Петрова',
        address: 'ул. Пушкина, 10',
        phoneNumber: '+7 999 765-43-21'
      }
    ]
  });
});

app.get('/api/test/posts', (req, res) => {
  res.json({
    success: true,
    data: [
      {
        id: '1',
        text: 'Привет, соседи! Кто знает, где можно купить хороший хлеб?',
        authorName: 'Иван Иванов',
        authorAddress: 'ул. Ленина, 1',
        createdAt: new Date().toISOString(),
        likesCount: 5,
        commentsCount: 3
      },
      {
        id: '2',
        text: 'Отдам даром детские игрушки. Дети выросли.',
        authorName: 'Мария Петрова',
        authorAddress: 'ул. Пушкина, 10',
        createdAt: new Date().toISOString(),
        likesCount: 12,
        commentsCount: 8
      }
    ]
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

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`🚀 Working Sosedi Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📡 Health check: http://localhost:${PORT}/api/health`);
  console.log(`👥 Test users: http://localhost:${PORT}/api/test/users`);
  console.log(`📝 Test posts: http://localhost:${PORT}/api/test/posts`);
});

module.exports = { app, server }; 