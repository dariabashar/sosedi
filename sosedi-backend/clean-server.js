const express = require("express");
const cors = require("cors");
const app = express();

app.use(cors());
app.use(express.json());

// Пустые массивы для хранения данных
const users = [];
const posts = [];
const groups = [];
const advertisements = [];
const events = [];
const chats = [];

// API Routes

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "Sosedi API is running (Clean Mode)!",
    timestamp: new Date().toISOString(),
    data: {
      users: users.length,
      posts: posts.length,
      groups: groups.length,
      advertisements: advertisements.length,
      events: events.length,
      chats: chats.length
    }
  });
});

// Users API
app.get("/api/users", (req, res) => {
  res.json({
    success: true,
    data: users,
    count: users.length
  });
});

app.get("/api/users/profile", (req, res) => {
  // Возвращаем пустой профиль или null
  res.json({
    success: true,
    data: null
  });
});

app.post("/api/users/profile", (req, res) => {
  const { firstName, lastName, phoneNumber, address, location } = req.body;
  
  const newUser = {
    id: Date.now().toString(),
    firstName,
    lastName,
    phoneNumber,
    address,
    location,
    createdAt: new Date()
  };
  
  users.push(newUser);
  
  res.json({
    success: true,
    data: newUser
  });
});

// Posts API
app.get("/api/posts/nearby", (req, res) => {
  res.json({
    success: true,
    data: posts
  });
});

app.post("/api/posts", (req, res) => {
  const { text, imagePath, location } = req.body;
  
  if (!text) {
    return res.status(400).json({
      success: false,
      message: "Text is required"
    });
  }
  
  const newPost = {
    id: Date.now().toString(),
    text,
    imagePath,
    location,
    author: {
      id: "current-user",
      firstName: "Пользователь",
      lastName: ""
    },
    createdAt: new Date(),
    likes: 0,
    comments: 0
  };
  
  posts.unshift(newPost);
  
  res.json({
    success: true,
    data: newPost
  });
});

// Groups API
app.get("/api/groups/nearby", (req, res) => {
  res.json({
    success: true,
    data: groups
  });
});

app.post("/api/groups", (req, res) => {
  const { name, description, location } = req.body;
  
  if (!name || !description) {
    return res.status(400).json({
      success: false,
      message: "Name and description are required"
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
app.get("/api/advertisements/nearby", (req, res) => {
  res.json({
    success: true,
    data: advertisements
  });
});

app.post("/api/advertisements", (req, res) => {
  const { title, description, type, price, imagePath, location } = req.body;
  
  if (!title || !description || !type) {
    return res.status(400).json({
      success: false,
      message: "Title, description and type are required"
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
      id: "current-user",
      firstName: "Пользователь",
      lastName: ""
    },
    createdAt: new Date()
  };
  
  advertisements.unshift(newAd);
  
  res.json({
    success: true,
    data: newAd
  });
});

// Events API
app.get("/api/events/nearby", (req, res) => {
  res.json({
    success: true,
    data: events
  });
});

app.post("/api/events", (req, res) => {
  const { title, date, location, description } = req.body;
  
  if (!title || !date || !location) {
    return res.status(400).json({
      success: false,
      message: "Title, date and location are required"
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
app.get("/api/chats", (req, res) => {
  res.json({
    success: true,
    data: chats
  });
});

app.post("/api/chats", (req, res) => {
  const { participantId, message } = req.body;
  
  if (!participantId || !message) {
    return res.status(400).json({
      success: false,
      message: "Participant ID and message are required"
    });
  }
  
  // Найти существующий чат или создать новый
  let chat = chats.find(c => 
    c.type === "private" && 
    c.participants.some(p => p.id === participantId)
  );
  
  if (!chat) {
    chat = {
      id: Date.now().toString(),
      type: "private",
      participants: [
        { id: "current-user", firstName: "Пользователь", lastName: "" },
        { id: participantId, firstName: "Сосед", lastName: "" }
      ],
      messages: [],
      createdAt: new Date()
    };
    chats.push(chat);
  }
  
  const newMessage = {
    id: Date.now().toString(),
    text: message,
    author: { id: "current-user", firstName: "Пользователь", lastName: "" },
    timestamp: new Date()
  };
  
  if (!chat.messages) chat.messages = [];
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

app.get("/api/chats/:chatId/messages", (req, res) => {
  const { chatId } = req.params;
  
  const chat = chats.find(c => c.id === chatId);
  
  if (!chat) {
    return res.status(404).json({
      success: false,
      message: "Chat not found"
    });
  }
  
  res.json({
    success: true,
    data: chat.messages || []
  });
});

app.post("/api/chats/create", (req, res) => {
  const { participantId, initialMessage } = req.body;
  
  if (!participantId) {
    return res.status(400).json({
      success: false,
      message: "Participant ID is required"
    });
  }
  
  const newChat = {
    id: Date.now().toString(),
    type: "private",
    participants: [
      { id: "current-user", firstName: "Пользователь", lastName: "" },
      { id: participantId, firstName: "Сосед", lastName: "" }
    ],
    messages: [],
    createdAt: new Date()
  };
  
  if (initialMessage) {
    const message = {
      id: Date.now().toString(),
      text: initialMessage,
      author: { id: "current-user", firstName: "Пользователь", lastName: "" },
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

app.listen(3000, () => {
  console.log("🚀 Sosedi Clean Server running on port 3000");
  console.log("✅ Ready for real user data");
  console.log("🌐 API available at http://localhost:3000/api");
  console.log("📱 Flutter app can now connect and create real content");
});
