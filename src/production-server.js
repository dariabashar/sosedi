require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Подключение к SQLite
const db = new sqlite3.Database('./sosedi.db', (err) => {
  if (err) {
    console.error('❌ Error opening database:', err.message);
  } else {
    console.log('✅ Connected to SQLite database');
    initDatabase();
  }
});

// Инициализация базы данных
function initDatabase() {
  db.serialize(() => {
    // Таблица пользователей
    db.run(`CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firebase_uid TEXT UNIQUE,
      first_name TEXT,
      last_name TEXT,
      phone_number TEXT,
      email TEXT,
      address TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);

    // Таблица постов
    db.run(`CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      author_id INTEGER,
      text TEXT,
      image_path TEXT,
      latitude REAL,
      longitude REAL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (author_id) REFERENCES users (id)
    )`);

    // Таблица чатов
    db.run(`CREATE TABLE IF NOT EXISTS chats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      participant1_id INTEGER,
      participant2_id INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (participant1_id) REFERENCES users (id),
      FOREIGN KEY (participant2_id) REFERENCES users (id)
    )`);

    // Таблица сообщений
    db.run(`CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      chat_id INTEGER,
      sender_id INTEGER,
      text TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (chat_id) REFERENCES chats (id),
      FOREIGN KEY (sender_id) REFERENCES users (id)
    )`);

    console.log('✅ Database tables created');
  });
}

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Sosedi API is running',
    timestamp: new Date().toISOString(),
    database: 'connected',
    version: '1.0.0',
  });
});

// Users API
app.get('/api/users', (req, res) => {
  db.all('SELECT * FROM users ORDER BY created_at DESC', (err, rows) => {
    if (err) {
      res.status(500).json({ success: false, message: err.message });
    } else {
      res.json({ success: true, data: rows, count: rows.length });
    }
  });
});

app.post('/api/users/profile', (req, res) => {
  const { firebaseUid, firstName, lastName, phoneNumber, address, location } = req.body;
  
  if (!firebaseUid) {
    return res.status(400).json({
      success: false,
      message: 'firebaseUid is required'
    });
  }
  
  // Проверяем, существует ли пользователь
  db.get('SELECT * FROM users WHERE firebase_uid = ?', [firebaseUid], (err, row) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    
    if (row) {
      // Обновляем существующего пользователя
      db.run(
        'UPDATE users SET first_name = ?, last_name = ?, phone_number = ?, address = ?, updated_at = CURRENT_TIMESTAMP WHERE firebase_uid = ?',
        [firstName, lastName, phoneNumber, address, firebaseUid],
        function(err) {
          if (err) {
            res.status(500).json({ success: false, message: err.message });
          } else {
            res.json({ success: true, message: 'User updated', userId: row.id });
          }
        }
      );
    } else {
      // Создаем нового пользователя
      db.run(
        'INSERT INTO users (firebase_uid, first_name, last_name, phone_number, address) VALUES (?, ?, ?, ?, ?)',
        [firebaseUid, firstName, lastName, phoneNumber, address],
        function(err) {
          if (err) {
            res.status(500).json({ success: false, message: err.message });
          } else {
            res.json({ success: true, message: 'User created', userId: this.lastID });
          }
        }
      );
    }
  });
});

// Posts API
app.get('/api/posts', (req, res) => {
  db.all(`
    SELECT p.*, u.first_name, u.last_name, u.address as author_address
    FROM posts p
    LEFT JOIN users u ON p.author_id = u.id
    ORDER BY p.created_at DESC
  `, (err, rows) => {
    if (err) {
      res.status(500).json({ success: false, message: err.message });
    } else {
      res.json({ success: true, data: rows, count: rows.length });
    }
  });
});

app.post('/api/posts', (req, res) => {
  const { text, imagePath, location, authorId } = req.body;
  
  if (!text || !authorId) {
    return res.status(400).json({
      success: false,
      message: 'text and authorId are required'
    });
  }
  
  db.run(
    'INSERT INTO posts (author_id, text, image_path, latitude, longitude) VALUES (?, ?, ?, ?, ?)',
    [authorId, text, imagePath, location?.latitude, location?.longitude],
    function(err) {
      if (err) {
        res.status(500).json({ success: false, message: err.message });
      } else {
        res.json({ success: true, message: 'Post created', postId: this.lastID });
      }
    }
  );
});

// Chats API
app.get('/api/chats', (req, res) => {
  db.all(`
    SELECT c.*, 
           u1.first_name as participant1_name, u1.last_name as participant1_last_name,
           u2.first_name as participant2_name, u2.last_name as participant2_last_name,
           (SELECT COUNT(*) FROM messages m WHERE m.chat_id = c.id) as message_count
    FROM chats c
    LEFT JOIN users u1 ON c.participant1_id = u1.id
    LEFT JOIN users u2 ON c.participant2_id = u2.id
    ORDER BY c.created_at DESC
  `, (err, rows) => {
    if (err) {
      res.status(500).json({ success: false, message: err.message });
    } else {
      res.json({ success: true, data: rows, count: rows.length });
    }
  });
});

// Обработка ошибок
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
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

app.listen(PORT, () => {
  console.log(`🚀 Sosedi Production Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`📡 Health check: http://localhost:${PORT}/api/health`);
  console.log(`💾 Database: SQLite (sosedi.db)`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  db.close((err) => {
    if (err) {
      console.error('❌ Error closing database:', err.message);
    } else {
      console.log('✅ Database connection closed');
    }
    process.exit(0);
  });
});
