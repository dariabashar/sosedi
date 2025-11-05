const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  text: {
    type: String,
    required: true,
    trim: true,
  },
  isRead: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

const chatSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['private', 'group'],
    required: true,
  },
  participants: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    joinedAt: {
      type: Date,
      default: Date.now,
    },
  }],
  // Для приватных чатов
  user1Id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  user2Id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  // Для групповых чатов
  groupId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Group',
  },
  groupName: {
    type: String,
  },
  messages: [messageSchema],
  lastMessage: {
    text: String,
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
  isDeleted: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

// Индексы
chatSchema.index({ 'participants.userId': 1 });
chatSchema.index({ user1Id: 1, user2Id: 1 });
chatSchema.index({ groupId: 1 });
chatSchema.index({ updatedAt: -1 });

// Виртуальные поля
chatSchema.virtual('unreadCount').get(function() {
  return this.messages.filter(message => !message.isRead).length;
});

// Метод для поиска чата между двумя пользователями
chatSchema.statics.findPrivateChat = function(user1Id, user2Id) {
  return this.findOne({
    type: 'private',
    $or: [
      { user1Id: user1Id, user2Id: user2Id },
      { user1Id: user2Id, user2Id: user1Id },
    ],
    isDeleted: false,
  });
};

// Метод для поиска группового чата
chatSchema.statics.findGroupChat = function(groupId) {
  return this.findOne({
    type: 'group',
    groupId: groupId,
    isDeleted: false,
  });
};

// Метод для добавления сообщения
chatSchema.methods.addMessage = function(senderId, text) {
  const message = {
    senderId,
    text,
    createdAt: new Date(),
  };
  
  this.messages.push(message);
  this.lastMessage = {
    text,
    senderId,
    createdAt: new Date(),
  };
  this.updatedAt = new Date();
  
  return this.save();
};

// Метод для отметки сообщений как прочитанных
chatSchema.methods.markAsRead = function(userId) {
  this.messages.forEach(message => {
    if (message.senderId.toString() !== userId.toString() && !message.isRead) {
      message.isRead = true;
    }
  });
  
  return this.save();
};

// Метод для проверки, является ли пользователь участником чата
chatSchema.methods.isParticipant = function(userId) {
  return this.participants.some(participant => 
    participant.userId.toString() === userId.toString()
  );
};

module.exports = mongoose.model('Chat', chatSchema); 