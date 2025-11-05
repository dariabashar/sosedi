require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const admin = require('firebase-admin');
const path = require('path');
const { Server } = require('socket.io');
const http = require('http');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('uploads'));

// MongoDB Connection
const connectDB = async () => {
  try {
    if (process.env.MONGODB_URI) {
      await mongoose.connect(process.env.MONGODB_URI);
      console.log('✅ MongoDB connected successfully');
    } else {
      console.log('⚠️  MongoDB URI not found, using in-memory data');
    }
  } catch (error) {
    console.log('❌ MongoDB connection failed:', error.message);
    console.log('⚠️  Server will run with in-memory data');
  }
};

// Firebase Admin SDK
const initializeFirebase = () => {
  try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
      const serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT_PATH);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      console.log('✅ Firebase Admin SDK initialized');
    } else {
      console.log('⚠️  Firebase credentials not found');
    }
  } catch (error) {
    console.log('❌ Firebase initialization failed:', error.message);
  }
};

// In-memory data storage (fallback)
let users = [
  { id: '1', firstName: 'Иван', lastName: 'Иванов', address: 'ул. Ленина, 1', phoneNumber: '+77001234567' }
];
let posts = [];
let groups = [];
let advertisements = [];
let events = [];
let chats = [];

// Authentication middleware
const authenticateUser = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'No token provided' });
    }

    const token = authHeader.split('Bearer ')[1];
    
    if (admin.apps.length > 0) {
      const decodedToken = await admin.auth().verifyIdToken(token);
      req.user = decodedToken;
    } else {
      // Fallback for testing
      req.user = { uid: 'test-user', phone_number: '+77001234567' };
    }
    
    next();
  } catch (error) {
    console.log('Auth error:', error.message);
    res.status(401).json({ success: false, message: 'Invalid token' });
  }
};

// Routes
app.get('/api/health', (req, res) => {
  res.json({ 
    success: true, 
    message: 'Sosedi API is running!', 
    timestamp: new Date().toISOString(),
    services: {
      mongodb: mongoose.connection.readyState === 1,
      firebase: admin.apps.length > 0
    }
  });
});

// Users
app.get('/api/users/profile', authenticateUser, (req, res) => {
  const user = users.find(u => u.phoneNumber === req.user.phone_number);
  if (user) {
    res.json({ success: true, data: user });
  } else {
    res.json({ success: true, data: null });
  }
});

app.post('/api/users', authenticateUser, (req, res) => {
  const { firstName, lastName, address } = req.body;
  const existingUser = users.find(u => u.phoneNumber === req.user.phone_number);
  
  if (existingUser) {
    Object.assign(existingUser, { firstName, lastName, address });
    res.json({ success: true, data: existingUser });
  } else {
    const newUser = {
      id: Date.now().toString(),
      firstName,
      lastName,
      address,
      phoneNumber: req.user.phone_number,
      createdAt: new Date()
    };
    users.push(newUser);
    res.json({ success: true, data: newUser });
  }
});

// Posts
app.get('/api/posts/nearby', authenticateUser, (req, res) => {
  res.json({ success: true, data: posts });
});

app.post('/api/posts', authenticateUser, (req, res) => {
  const { text, imagePath, location } = req.body;
  const newPost = {
    id: Date.now().toString(),
    authorId: req.user.uid,
    text,
    imagePath,
    location,
    createdAt: new Date(),
    likedBy: [],
    comments: []
  };
  posts.push(newPost);
  res.json({ success: true, data: newPost });
});

// Groups
app.get('/api/groups/nearby', authenticateUser, (req, res) => {
  res.json({ success: true, data: groups });
});

app.post('/api/groups', authenticateUser, (req, res) => {
  const { name, description, location } = req.body;
  const newGroup = {
    id: Date.now().toString(),
    name,
    description,
    authorId: req.user.uid,
    location,
    members: [req.user.uid],
    createdAt: new Date()
  };
  groups.push(newGroup);
  res.json({ success: true, data: newGroup });
});

// Advertisements
app.get('/api/advertisements/nearby', authenticateUser, (req, res) => {
  res.json({ success: true, data: advertisements });
});

app.post('/api/advertisements', authenticateUser, (req, res) => {
  const { title, description, type, price, imagePath, location } = req.body;
  const newAd = {
    id: Date.now().toString(),
    title,
    description,
    type,
    authorId: req.user.uid,
    price,
    imagePath,
    location,
    createdAt: new Date(),
    interestedUsers: []
  };
  advertisements.push(newAd);
  res.json({ success: true, data: newAd });
});

// Events
app.get('/api/events/nearby', authenticateUser, (req, res) => {
  res.json({ success: true, data: events });
});

app.post('/api/events', authenticateUser, (req, res) => {
  const { title, date, location, description } = req.body;
  const newEvent = {
    id: Date.now().toString(),
    title,
    date,
    location,
    description,
    authorId: req.user.uid,
    participants: [req.user.uid],
    createdAt: new Date()
  };
  events.push(newEvent);
  res.json({ success: true, data: newEvent });
});

// Chats
app.get('/api/chats', authenticateUser, (req, res) => {
  const userChats = chats.filter(chat => 
    chat.participants.includes(req.user.uid)
  );
  res.json({ success: true, data: userChats });
});

app.post('/api/chats', authenticateUser, (req, res) => {
  const { participantId, message } = req.body;
  const existingChat = chats.find(chat => 
    chat.participants.includes(req.user.uid) && 
    chat.participants.includes(participantId) &&
    chat.type === 'private'
  );
  
  if (existingChat) {
    existingChat.messages.push({
      id: Date.now().toString(),
      senderId: req.user.uid,
      text: message,
      timestamp: new Date()
    });
    res.json({ success: true, data: existingChat });
  } else {
    const newChat = {
      id: Date.now().toString(),
      type: 'private',
      participants: [req.user.uid, participantId],
      messages: [{
        id: Date.now().toString(),
        senderId: req.user.uid,
        text: message,
        timestamp: new Date()
      }],
      createdAt: new Date()
    };
    chats.push(newChat);
    res.json({ success: true, data: newChat });
  }
});

// Socket.IO for real-time chat
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);
  
  socket.on('join-chat', (chatId) => {
    socket.join(chatId);
    console.log(`User ${socket.id} joined chat ${chatId}`);
  });
  
  socket.on('send-message', (data) => {
    const { chatId, message } = data;
    const chat = chats.find(c => c.id === chatId);
    
    if (chat) {
      const newMessage = {
        id: Date.now().toString(),
        senderId: socket.userId,
        text: message,
        timestamp: new Date()
      };
      chat.messages.push(newMessage);
      
      io.to(chatId).emit('new-message', {
        chatId,
        message: newMessage
      });
    }
  });
  
  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Start server
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  await connectDB();
  initializeFirebase();
  
  server.listen(PORT, () => {
    console.log(`🚀 Sosedi Server running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🔗 MongoDB: ${mongoose.connection.readyState === 1 ? 'Connected' : 'Not connected'}`);
    console.log(`🔥 Firebase: ${admin.apps.length > 0 ? 'Initialized' : 'Not initialized'}`);
  });
};

startServer(); 