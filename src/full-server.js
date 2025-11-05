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
    data: user,
    message: user.id ? 'User created' : 'User updated'
  });
});

// Posts API
app.get('/api/posts', (req, res) => {
  const { lat, lng, radius = 1000 } = req.query;
  
  let filteredPosts = posts;
  
  // Фильтрация по геолокации
  if (lat && lng) {
    filteredPosts = posts.filter(post => {
      if (!post.location) return false;
      
      const distance = calculateDistance(
        parseFloat(lat),
        parseFloat(lng),
        post.location.coordinates[1],
        post.location.coordinates[0]
      );
      
      return distance <= radius;
    });
  }
  
  res.json({
    success: true,
    data: filteredPosts,
    count: filteredPosts.length
  });
});

app.post('/api/posts', (req, res) => {
  const { authorId, text, imagePath, location } = req.body;
  
  if (!authorId || !text) {
    return res.status(400).json({
      success: false,
      message: 'authorId and text are required'
    });
  }
  
  const post = {
    id: Date.now().toString(),
    authorId,
    text,
    imagePath,
    location,
    likesCount: 0,
    commentsCount: 0,
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  posts.push(post);
  
  res.json({
    success: true,
    data: post,
    message: 'Post created successfully'
  });
});

// Groups API
app.get('/api/groups', (req, res) => {
  const { lat, lng, radius = 1000 } = req.query;
  
  let filteredGroups = groups;
  
  // Фильтрация по геолокации
  if (lat && lng) {
    filteredGroups = groups.filter(group => {
      if (!group.location) return false;
      
      const distance = calculateDistance(
        parseFloat(lat),
        parseFloat(lng),
        group.location.coordinates[1],
        group.location.coordinates[0]
      );
      
      return distance <= radius;
    });
  }
  
  res.json({
    success: true,
    data: filteredGroups,
    count: filteredGroups.length
  });
});

app.post('/api/groups', (req, res) => {
  const { name, description, authorId, location } = req.body;
  
  if (!name || !authorId) {
    return res.status(400).json({
      success: false,
      message: 'name and authorId are required'
    });
  }
  
  const group = {
    id: Date.now().toString(),
    name,
    description,
    authorId,
    location,
    members: [authorId],
    membersCount: 1,
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  groups.push(group);
  
  res.json({
    success: true,
    data: group,
    message: 'Group created successfully'
  });
});

// Advertisements API
app.get('/api/advertisements', (req, res) => {
  const { lat, lng, radius = 1000, type } = req.query;
  
  let filteredAds = advertisements;
  
  // Фильтрация по типу
  if (type) {
    filteredAds = filteredAds.filter(ad => ad.type === type);
  }
  
  // Фильтрация по геолокации
  if (lat && lng) {
    filteredAds = filteredAds.filter(ad => {
      if (!ad.location) return false;
      
      const distance = calculateDistance(
        parseFloat(lat),
        parseFloat(lng),
        ad.location.coordinates[1],
        ad.location.coordinates[0]
      );
      
      return distance <= radius;
    });
  }
  
  res.json({
    success: true,
    data: filteredAds,
    count: filteredAds.length
  });
});

app.post('/api/advertisements', (req, res) => {
  const { title, description, type, authorId, location, price, imagePath } = req.body;
  
  if (!title || !authorId) {
    return res.status(400).json({
      success: false,
      message: 'title and authorId are required'
    });
  }
  
  const advertisement = {
    id: Date.now().toString(),
    title,
    description,
    type: type || 'sale',
    authorId,
    location,
    price,
    imagePath,
    interestedUsers: [],
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  advertisements.push(advertisement);
  
  res.json({
    success: true,
    data: advertisement,
    message: 'Advertisement created successfully'
  });
});

// Events API
app.get('/api/events', (req, res) => {
  const { lat, lng, radius = 1000 } = req.query;
  
  let filteredEvents = events;
  
  // Фильтрация по геолокации
  if (lat && lng) {
    filteredEvents = events.filter(event => {
      if (!event.coordinates) return false;
      
      const distance = calculateDistance(
        parseFloat(lat),
        parseFloat(lng),
        event.coordinates[1],
        event.coordinates[0]
      );
      
      return distance <= radius;
    });
  }
  
  res.json({
    success: true,
    data: filteredEvents,
    count: filteredEvents.length
  });
});

app.post('/api/events', (req, res) => {
  const { title, description, date, location, coordinates, authorId } = req.body;
  
  if (!title || !date || !authorId) {
    return res.status(400).json({
      success: false,
      message: 'title, date and authorId are required'
    });
  }
  
  const event = {
    id: Date.now().toString(),
    title,
    description,
    date: new Date(date),
    location,
    coordinates,
    authorId,
    participants: [authorId],
    participantsCount: 1,
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  events.push(event);
  
  res.json({
    success: true,
    data: event,
    message: 'Event created successfully'
  });
});

// Chats API
app.get('/api/chats', (req, res) => {
  const { userId } = req.query;
  
  if (!userId) {
    return res.status(400).json({
      success: false,
      message: 'userId is required'
    });
  }
  
  const userChats = chats.filter(chat => 
    chat.participants.includes(userId)
  );
  
  res.json({
    success: true,
    data: userChats,
    count: userChats.length
  });
});

app.post('/api/chats/private', (req, res) => {
  const { participant1, participant2 } = req.body;
  
  if (!participant1 || !participant2) {
    return res.status(400).json({
      success: false,
      message: 'participant1 and participant2 are required'
    });
  }
  
  // Проверить, существует ли уже чат
  const existingChat = chats.find(chat => 
    chat.type === 'private' &&
    chat.participants.includes(participant1) &&
    chat.participants.includes(participant2)
  );
  
  if (existingChat) {
    return res.json({
      success: true,
      data: existingChat,
      message: 'Chat already exists'
    });
  }
  
  const chat = {
    id: Date.now().toString(),
    type: 'private',
    participants: [participant1, participant2],
    messages: [],
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  chats.push(chat);
  
  res.json({
    success: true,
    data: chat,
    message: 'Private chat created successfully'
  });
});

// Utility function to calculate distance between two points
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of the Earth in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  const distance = R * c; // Distance in kilometers
  return distance * 1000; // Convert to meters
}

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
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('authenticate', async (token) => {
    try {
      // Здесь должна быть верификация Firebase токена
      socket.emit('authenticated');
    } catch (error) {
      socket.emit('auth_error', { message: 'Authentication failed' });
    }
  });

  socket.on('join_chat', (chatId) => {
    socket.join(`chat_${chatId}`);
    console.log(`User ${socket.id} joined chat ${chatId}`);
  });

  socket.on('send_message', (data) => {
    const { chatId, message } = data;
    socket.to(`chat_${chatId}`).emit('new_message', {
      chatId,
      message,
      timestamp: new Date(),
    });
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3000;

// Запуск сервера
const startServer = async () => {
  await connectDB();
  
  server.listen(PORT, () => {
    console.log(`🚀 Full Sosedi Server running on port ${PORT}`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`📡 Health check: http://localhost:${PORT}/api/health`);
    console.log(`👥 Users API: http://localhost:${PORT}/api/users`);
    console.log(`📝 Posts API: http://localhost:${PORT}/api/posts`);
    console.log(`👥 Groups API: http://localhost:${PORT}/api/groups`);
    console.log(`🛍️  Ads API: http://localhost:${PORT}/api/advertisements`);
    console.log(`🎉 Events API: http://localhost:${PORT}/api/events`);
    console.log(`💬 Chats API: http://localhost:${PORT}/api/chats`);
  });
};

startServer().catch(console.error);

module.exports = { app, server, io }; 