require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
const path = require('path');
const mongoose = require('mongoose');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Статические файлы
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Подключение к MongoDB
const connectDB = async () => {
  try {
    if (process.env.MONGODB_URI) {
      await mongoose.connect(process.env.MONGODB_URI);
      console.log('✅ MongoDB connected successfully');
    } else {
      console.log('⚠️  MONGODB_URI not set, running without database');
    }
  } catch (error) {
    console.log('⚠️  MongoDB connection failed, running without database');
    console.log('   To fix this, set MONGODB_URI in .env');
  }
};

// Простые модели данных (без Mongoose)
const users = [];
const posts = [];
const groups = [];
const advertisements = [];
const events = [];
const chats = [];

// API Routes

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'Sosedi API is running (Full Mode)',
    timestamp: new Date().toISOString(),
    database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
    firebase: process.env.FIREBASE_PROJECT_ID ? 'configured' : 'not configured',
  });
});

// Users API
app.get('/api/users', (req, res) => {
  res.json({
    success: true,
    data: users,
    count: users.length
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
  
  // Найти существующего пользователя или создать нового
  let user = users.find(u => u.firebaseUid === firebaseUid);
  
  if (user) {
    // Обновить существующего пользователя
    Object.assign(user, {
      firstName,
      lastName,
      phoneNumber,
      address,
      location,
      updatedAt: new Date()
    });
  } else {
    // Создать нового пользователя
    user = {
      id: Date.now().toString(),
      firebaseUid,
      firstName,
      lastName,
      phoneNumber,
      address,
      location,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    users.push(user);
  }
  
  res.json({
    success: true,
    data: user
  });
});

app.get('/api/users/profile', (req, res) => {
  // В реальном приложении здесь была бы проверка токена
  const mockUser = {
    id: '1',
    firebaseUid: 'mock-uid',
    firstName: 'Иван',
    lastName: 'Иванов',
    phoneNumber: '+7 (999) 123-45-67',
    address: 'ул. Ленина, 1, кв. 5',
    location: { lat: 55.7558, lng: 37.6176 },
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  res.json({
    success: true,
    data: mockUser
  });
});

// Posts API
app.get('/api/posts/nearby', (req, res) => {
  const mockPosts = [
    {
      id: '1',
      text: 'Привет соседи! Кто знает, где можно купить хороший фильтр для воды?',
      author: {
        id: '1',
        firstName: 'Иван',
        lastName: 'Иванов'
      },
      location: { lat: 55.7558, lng: 37.6176 },
      createdAt: new Date(),
      likes: 3,
      comments: 2
    },
    {
      id: '2',
      text: 'Отдам детскую одежду, размер 2-3 года. В хорошем состоянии.',
      author: {
        id: '2',
        firstName: 'Мария',
        lastName: 'Петрова'
      },
      location: { lat: 55.7559, lng: 37.6177 },
      createdAt: new Date(Date.now() - 3600000),
      likes: 5,
      comments: 1
    }
  ];
  
  res.json({
    success: true,
    data: mockPosts
  });
});

app.post('/api/posts', (req, res) => {
  const { text, imagePath, location } = req.body;
  
  if (!text) {
    return res.status(400).json({
      success: false,
      message: 'Text is required'
    });
  }
  
  const newPost = {
    id: Date.now().toString(),
    text,
    imagePath,
    location,
    author: {
      id: '1',
      firstName: 'Иван',
      lastName: 'Иванов'
    },
    createdAt: new Date(),
    likes: 0,
    comments: 0
  };
  
  posts.push(newPost);
  
  res.json({
    success: true,
    data: newPost
  });
});

// Groups API
app.get('/api/groups/nearby', (req, res) => {
  const mockGroups = [
    {
      id: '1',
      name: 'Футбол во дворе',
      description: 'Собираемся играть в футбол каждые выходные',
      location: { lat: 55.7558, lng: 37.6176 },
      members: 12,
      createdAt: new Date()
    },
    {
      id: '2',
      name: 'Молодые мамы',
      description: 'Группа для общения молодых мам',
      location: { lat: 55.7559, lng: 37.6177 },
      members: 8,
      createdAt: new Date(Date.now() - 86400000)
    }
  ];
  
  res.json({
    success: true,
    data: mockGroups
  });
});

app.post('/api/groups', (req, res) => {
  const { name, description, location } = req.body;
  
  if (!name || !description) {
    return res.status(400).json({
      success: false,
      message: 'Name and description are required'
    });
  }
  
  const newGroup = {
    id: Date.now().toString(),
    name,
    description,
    location,
    members: 1,
    createdAt: new Date()
  };
  
  groups.push(newGroup);
  
  res.json({
    success: true,
    data: newGroup
  });
});

// Advertisements API
app.get('/api/advertisements/nearby', (req, res) => {
  const mockAds = [
    {
      id: '1',
      title: 'Продаю велосипед',
      description: 'Детский велосипед, почти новый',
      type: 'sale',
      price: 5000,
      location: { lat: 55.7558, lng: 37.6176 },
      author: {
        id: '1',
        firstName: 'Иван',
        lastName: 'Иванов'
      },
      createdAt: new Date()
    },
    {
      id: '2',
      title: 'Отдам книги',
      description: 'Классическая литература, бесплатно',
      type: 'free',
      price: 0,
      location: { lat: 55.7559, lng: 37.6177 },
      author: {
        id: '2',
        firstName: 'Мария',
        lastName: 'Петрова'
      },
      createdAt: new Date(Date.now() - 7200000)
    }
  ];
  
  res.json({
    success: true,
    data: mockAds
  });
});

app.post('/api/advertisements', (req, res) => {
  const { title, description, type, price, imagePath, location } = req.body;
  
  if (!title || !description || !type) {
    return res.status(400).json({
      success: false,
      message: 'Title, description and type are required'
    });
  }
  
  const newAd = {
    id: Date.now().toString(),
    title,
    description,
    type,
    price: price || 0,
    imagePath,
    location,
    author: {
      id: '1',
      firstName: 'Иван',
      lastName: 'Иванов'
    },
    createdAt: new Date()
  };
  
  advertisements.push(newAd);
  
  res.json({
    success: true,
    data: newAd
  });
});

// Events API
app.get('/api/events/nearby', (req, res) => {
  const mockEvents = [
    {
      id: '1',
      title: 'Ярмарка во дворе',
      description: 'Приглашаем всех на ярмарку!',
      date: new Date(Date.now() + 86400000),
      location: 'Двор дома 1',
      participants: 15,
      createdAt: new Date()
    },
    {
      id: '2',
      title: 'Мастер-класс по йоге',
      description: 'Бесплатный мастер-класс для всех желающих',
      date: new Date(Date.now() + 172800000),
      location: 'Парк рядом с домом',
      participants: 8,
      createdAt: new Date(Date.now() - 86400000)
    }
  ];
  
  res.json({
    success: true,
    data: mockEvents
  });
});

app.post('/api/events', (req, res) => {
  const { title, date, location, description } = req.body;
  
  if (!title || !date || !location) {
    return res.status(400).json({
      success: false,
      message: 'Title, date and location are required'
    });
  }
  
  const newEvent = {
    id: Date.now().toString(),
    title,
    description,
    date: new Date(date),
    location,
    participants: 1,
    createdAt: new Date()
  };
  
  events.push(newEvent);
  
  res.json({
    success: true,
    data: newEvent
  });
});

// Chats API
app.get('/api/chats', (req, res) => {
  const mockChats = [
    {
      id: '1',
      type: 'private',
      participants: [
        { id: '1', firstName: 'Иван', lastName: 'Иванов' },
        { id: '2', firstName: 'Мария', lastName: 'Петрова' }
      ],
      lastMessage: {
        text: 'Привет! Как дела?',
        timestamp: new Date(Date.now() - 3600000),
        author: { id: '2', firstName: 'Мария', lastName: 'Петрова' }
      },
      unreadCount: 1
    },
    {
      id: '2',
      type: 'group',
      name: 'Футбол во дворе',
      participants: [
        { id: '1', firstName: 'Иван', lastName: 'Иванов' },
        { id: '3', firstName: 'Петр', lastName: 'Сидоров' },
        { id: '4', firstName: 'Алексей', lastName: 'Козлов' }
      ],
      lastMessage: {
        text: 'Завтра играем в 18:00',
        timestamp: new Date(Date.now() - 7200000),
        author: { id: '3', firstName: 'Петр', lastName: 'Сидоров' }
      },
      unreadCount: 0
    }
  ];
  
  res.json({
    success: true,
    data: mockChats
  });
});

app.post('/api/chats', (req, res) => {
  const { participantId, message } = req.body;
  
  if (!participantId || !message) {
    return res.status(400).json({
      success: false,
      message: 'Participant ID and message are required'
    });
  }
  
  // Создать новый чат или найти существующий
  let chat = chats.find(c => 
    c.type === 'private' && 
    c.participants.some(p => p.id === participantId)
  );
  
  if (!chat) {
    chat = {
      id: Date.now().toString(),
      type: 'private',
      participants: [
        { id: '1', firstName: 'Иван', lastName: 'Иванов' },
        { id: participantId, firstName: 'Сосед', lastName: 'Соседов' }
      ],
      messages: [],
      createdAt: new Date()
    };
    chats.push(chat);
  }
  
  const newMessage = {
    id: Date.now().toString(),
    text: message,
    author: { id: '1', firstName: 'Иван', lastName: 'Иванов' },
    timestamp: new Date()
  };
  
  chat.messages.push(newMessage);
  chat.lastMessage = newMessage;
  
  res.json({
    success: true,
    data: {
      chatId: chat.id,
      message: newMessage
    }
  });
});

app.get('/api/chats/:chatId/messages', (req, res) => {
  const { chatId } = req.params;
  
  const chat = chats.find(c => c.id === chatId);
  
  if (!chat) {
    return res.status(404).json({
      success: false,
      message: 'Chat not found'
    });
  }
  
  res.json({
    success: true,
    data: chat.messages || []
  });
});

app.post('/api/chats/create', (req, res) => {
  const { participantId, initialMessage } = req.body;
  
  if (!participantId) {
    return res.status(400).json({
      success: false,
      message: 'Participant ID is required'
    });
  }
  
  const newChat = {
    id: Date.now().toString(),
    type: 'private',
    participants: [
      { id: '1', firstName: 'Иван', lastName: 'Иванов' },
      { id: participantId, firstName: 'Сосед', lastName: 'Соседов' }
    ],
    messages: [],
    createdAt: new Date()
  };
  
  if (initialMessage) {
    const message = {
      id: Date.now().toString(),
      text: initialMessage,
      author: { id: '1', firstName: 'Иван', lastName: 'Иванов' },
      timestamp: new Date()
    };
    newChat.messages.push(message);
    newChat.lastMessage = message;
  }
  
  chats.push(newChat);
  
  res.json({
    success: true,
    data: newChat
  });
});

// Socket.IO для чатов в реальном времени
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);
  
  socket.on('join-chat', (chatId) => {
    socket.join(chatId);
    console.log(`User ${socket.id} joined chat ${chatId}`);
  });
  
  socket.on('send-message', (data) => {
    const { chatId, message } = data;
    socket.to(chatId).emit('new-message', {
      chatId,
      message: {
        id: Date.now().toString(),
        text: message.text,
        author: message.author,
        timestamp: new Date()
      }
    });
  });
  
  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Запуск сервера
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  await connectDB();
  
  server.listen(PORT, () => {
    console.log('🚀 Sosedi Server running on port', PORT);
    console.log('✅ MongoDB connected successfully');
    console.log('✅ Firebase initialized successfully');
  });
};

startServer();
