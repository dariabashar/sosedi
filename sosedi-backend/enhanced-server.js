const express = require("express");
const cors = require("cors");
const app = express();

app.use(cors());
app.use(express.json());

// Тестовые данные
const mockUsers = [
  {
    id: "1",
    firstName: "Иван",
    lastName: "Иванов",
    phoneNumber: "+7 (999) 123-45-67",
    address: "ул. Ленина, 1, кв. 5",
    location: { lat: 55.7558, lng: 37.6176 }
  },
  {
    id: "2", 
    firstName: "Мария",
    lastName: "Петрова",
    phoneNumber: "+7 (999) 234-56-78",
    address: "ул. Пушкина, 10, кв. 12",
    location: { lat: 55.7559, lng: 37.6177 }
  },
  {
    id: "3",
    firstName: "Петр",
    lastName: "Сидоров", 
    phoneNumber: "+7 (999) 345-67-89",
    address: "ул. Гагарина, 25, кв. 8",
    location: { lat: 55.7560, lng: 37.6178 }
  }
];

const mockPosts = [
  {
    id: "1",
    text: "Привет соседи! Кто знает, где можно купить хороший фильтр для воды?",
    author: mockUsers[0],
    location: { lat: 55.7558, lng: 37.6176 },
    createdAt: new Date(),
    likes: 3,
    comments: 2
  },
  {
    id: "2",
    text: "Отдам детскую одежду, размер 2-3 года. В хорошем состоянии.",
    author: mockUsers[1],
    location: { lat: 55.7559, lng: 37.6177 },
    createdAt: new Date(Date.now() - 3600000),
    likes: 5,
    comments: 1
  },
  {
    id: "3",
    text: "Завтра играем в футбол во дворе в 18:00. Кто с нами?",
    author: mockUsers[2],
    location: { lat: 55.7560, lng: 37.6178 },
    createdAt: new Date(Date.now() - 7200000),
    likes: 8,
    comments: 4
  }
];

const mockGroups = [
  {
    id: "1",
    name: "Футбол во дворе",
    description: "Собираемся играть в футбол каждые выходные",
    location: { lat: 55.7558, lng: 37.6176 },
    members: 12,
    createdAt: new Date()
  },
  {
    id: "2",
    name: "Молодые мамы",
    description: "Группа для общения молодых мам",
    location: { lat: 55.7559, lng: 37.6177 },
    members: 8,
    createdAt: new Date(Date.now() - 86400000)
  },
  {
    id: "3",
    name: "Шахматы ЖК Энергетик",
    description: "Играем в шахматы по вечерам",
    location: { lat: 55.7560, lng: 37.6178 },
    members: 6,
    createdAt: new Date(Date.now() - 172800000)
  }
];

const mockAdvertisements = [
  {
    id: "1",
    title: "Продаю велосипед",
    description: "Детский велосипед, почти новый, размер 16 дюймов",
    type: "sale",
    price: 5000,
    location: { lat: 55.7558, lng: 37.6176 },
    author: mockUsers[0],
    createdAt: new Date()
  },
  {
    id: "2",
    title: "Отдам книги",
    description: "Классическая литература, бесплатно. Приходите забирать",
    type: "free",
    price: 0,
    location: { lat: 55.7559, lng: 37.6177 },
    author: mockUsers[1],
    createdAt: new Date(Date.now() - 7200000)
  },
  {
    id: "3",
    title: "Нужна помощь с переездом",
    description: "Ищу помощников для переезда в субботу. Оплата 1000 руб/час",
    type: "help",
    price: 1000,
    location: { lat: 55.7560, lng: 37.6178 },
    author: mockUsers[2],
    createdAt: new Date(Date.now() - 14400000)
  }
];

const mockEvents = [
  {
    id: "1",
    title: "Ярмарка во дворе",
    description: "Приглашаем всех на ярмарку! Будет много интересного",
    date: new Date(Date.now() + 86400000),
    location: "Двор дома 1",
    participants: 15,
    createdAt: new Date()
  },
  {
    id: "2",
    title: "Мастер-класс по йоге",
    description: "Бесплатный мастер-класс для всех желающих",
    date: new Date(Date.now() + 172800000),
    location: "Парк рядом с домом",
    participants: 8,
    createdAt: new Date(Date.now() - 86400000)
  },
  {
    id: "3",
    title: "Сбор макулатуры",
    description: "Экологическая акция. Приносите старые газеты и журналы",
    date: new Date(Date.now() + 259200000),
    location: "Контейнеры у подъездов",
    participants: 25,
    createdAt: new Date(Date.now() - 172800000)
  }
];

const mockChats = [
  {
    id: "1",
    type: "private",
    participants: [mockUsers[0], mockUsers[1]],
    lastMessage: {
      text: "Привет! Как дела?",
      timestamp: new Date(Date.now() - 3600000),
      author: mockUsers[1]
    },
    unreadCount: 1
  },
  {
    id: "2",
    type: "group",
    name: "Футбол во дворе",
    participants: [mockUsers[0], mockUsers[2]],
    lastMessage: {
      text: "Завтра играем в 18:00",
      timestamp: new Date(Date.now() - 7200000),
      author: mockUsers[2]
    },
    unreadCount: 0
  }
];

// API Routes

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "Sosedi API is running (Enhanced Mode)!",
    timestamp: new Date().toISOString(),
    data: {
      users: mockUsers.length,
      posts: mockPosts.length,
      groups: mockGroups.length,
      advertisements: mockAdvertisements.length,
      events: mockEvents.length,
      chats: mockChats.length
    }
  });
});

// Users API
app.get("/api/users", (req, res) => {
  res.json({
    success: true,
    data: mockUsers,
    count: mockUsers.length
  });
});

app.get("/api/users/profile", (req, res) => {
  res.json({
    success: true,
    data: mockUsers[0] // Возвращаем первого пользователя как текущего
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
  
  mockUsers.push(newUser);
  
  res.json({
    success: true,
    data: newUser
  });
});

// Posts API
app.get("/api/posts/nearby", (req, res) => {
  res.json({
    success: true,
    data: mockPosts
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
    author: mockUsers[0],
    createdAt: new Date(),
    likes: 0,
    comments: 0
  };
  
  mockPosts.unshift(newPost); // Добавляем в начало списка
  
  res.json({
    success: true,
    data: newPost
  });
});

// Groups API
app.get("/api/groups/nearby", (req, res) => {
  res.json({
    success: true,
    data: mockGroups
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
  
  mockGroups.push(newGroup);
  
  res.json({
    success: true,
    data: newGroup
  });
});

// Advertisements API
app.get("/api/advertisements/nearby", (req, res) => {
  res.json({
    success: true,
    data: mockAdvertisements
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
    author: mockUsers[0],
    createdAt: new Date()
  };
  
  mockAdvertisements.unshift(newAd);
  
  res.json({
    success: true,
    data: newAd
  });
});

// Events API
app.get("/api/events/nearby", (req, res) => {
  res.json({
    success: true,
    data: mockEvents
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
  
  mockEvents.push(newEvent);
  
  res.json({
    success: true,
    data: newEvent
  });
});

// Chats API
app.get("/api/chats", (req, res) => {
  res.json({
    success: true,
    data: mockChats
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
  let chat = mockChats.find(c => 
    c.type === "private" && 
    c.participants.some(p => p.id === participantId)
  );
  
  if (!chat) {
    const participant = mockUsers.find(u => u.id === participantId) || mockUsers[1];
    chat = {
      id: Date.now().toString(),
      type: "private",
      participants: [mockUsers[0], participant],
      messages: [],
      createdAt: new Date()
    };
    mockChats.push(chat);
  }
  
  const newMessage = {
    id: Date.now().toString(),
    text: message,
    author: mockUsers[0],
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
  
  const chat = mockChats.find(c => c.id === chatId);
  
  if (!chat) {
    return res.status(404).json({
      success: false,
      message: "Chat not found"
    });
  }
  
  // Создаем тестовые сообщения для чата
  const messages = chat.messages || [
    {
      id: "1",
      text: "Привет! Как дела?",
      author: chat.participants[1],
      timestamp: new Date(Date.now() - 3600000)
    },
    {
      id: "2", 
      text: "Привет! Все хорошо, спасибо!",
      author: mockUsers[0],
      timestamp: new Date(Date.now() - 1800000)
    }
  ];
  
  res.json({
    success: true,
    data: messages
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
  
  const participant = mockUsers.find(u => u.id === participantId) || mockUsers[1];
  
  const newChat = {
    id: Date.now().toString(),
    type: "private",
    participants: [mockUsers[0], participant],
    messages: [],
    createdAt: new Date()
  };
  
  if (initialMessage) {
    const message = {
      id: Date.now().toString(),
      text: initialMessage,
      author: mockUsers[0],
      timestamp: new Date()
    };
    newChat.messages.push(message);
    newChat.lastMessage = message;
  }
  
  mockChats.push(newChat);
  
  res.json({
    success: true,
    data: newChat
  });
});

// Test endpoint для демонстрации
app.get("/api/test/users", (req, res) => {
  res.json({
    success: true,
    data: mockUsers
  });
});

app.get("/api/test/posts", (req, res) => {
  res.json({
    success: true,
    data: mockPosts
  });
});

app.get("/api/test/groups", (req, res) => {
  res.json({
    success: true,
    data: mockGroups
  });
});

app.get("/api/test/advertisements", (req, res) => {
  res.json({
    success: true,
    data: mockAdvertisements
  });
});

app.get("/api/test/events", (req, res) => {
  res.json({
    success: true,
    data: mockEvents
  });
});

app.get("/api/test/chats", (req, res) => {
  res.json({
    success: true,
    data: mockChats
  });
});

app.listen(3000, () => {
  console.log("🚀 Sosedi Enhanced Server running on port 3000");
  console.log("✅ Test data loaded:");
  console.log(`   - ${mockUsers.length} users`);
  console.log(`   - ${mockPosts.length} posts`);
  console.log(`   - ${mockGroups.length} groups`);
  console.log(`   - ${mockAdvertisements.length} advertisements`);
  console.log(`   - ${mockEvents.length} events`);
  console.log(`   - ${mockChats.length} chats`);
  console.log("🌐 API available at http://localhost:3000/api");
});
