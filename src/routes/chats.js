const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Chat = require('../models/Chat');
const User = require('../models/User');

// Получить список чатов пользователя
router.get('/', auth, async (req, res) => {
  try {
    const chats = await Chat.find({
      'participants.userId': req.user._id,
      isDeleted: false,
    })
    .populate('participants.userId', 'firstName lastName displayName avatarUrl')
    .populate('lastMessage.senderId', 'firstName lastName displayName')
    .sort({ updatedAt: -1 });
    
    // Форматируем чаты для фронтенда
    const formattedChats = chats.map(chat => {
      const chatData = chat.toObject();
      
      if (chat.type === 'private') {
        // Для приватных чатов находим собеседника
        const otherParticipant = chat.participants.find(
          p => p.userId._id.toString() !== req.user._id.toString()
        );
        
        chatData.otherUserName = otherParticipant?.userId?.fullName || 'Unknown User';
        chatData.otherUserAddress = otherParticipant?.userId?.address || '';
      }
      
      return chatData;
    });
    
    res.json({
      success: true,
      data: formattedChats,
    });
  } catch (error) {
    console.error('Get chats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Создать или получить приватный чат с пользователем
router.post('/private', auth, async (req, res) => {
  try {
    const { userId } = req.body;
    
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }
    
    // Проверяем, существует ли пользователь
    const otherUser = await User.findById(userId);
    if (!otherUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }
    
    // Ищем существующий чат
    let chat = await Chat.findPrivateChat(req.user._id, userId);
    
    if (!chat) {
      // Создаем новый чат
      chat = new Chat({
        type: 'private',
        user1Id: req.user._id,
        user2Id: userId,
        participants: [
          { userId: req.user._id },
          { userId: userId },
        ],
        messages: [],
      });
      
      await chat.save();
    }
    
    // Загружаем сообщения
    await chat.populate('participants.userId', 'firstName lastName displayName avatarUrl');
    
    res.json({
      success: true,
      data: chat,
    });
  } catch (error) {
    console.error('Create private chat error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Получить сообщения чата
router.get('/:id/messages', auth, async (req, res) => {
  try {
    const chat = await Chat.findById(req.params.id);
    
    if (!chat) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found',
      });
    }
    
    if (!chat.isParticipant(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this chat',
      });
    }
    
    // Отмечаем сообщения как прочитанные
    await chat.markAsRead(req.user._id);
    
    res.json({
      success: true,
      data: chat.messages,
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Отправить сообщение в чат
router.post('/:id/messages', auth, async (req, res) => {
  try {
    const { text } = req.body;
    
    if (!text) {
      return res.status(400).json({
        success: false,
        message: 'Message text is required',
      });
    }
    
    const chat = await Chat.findById(req.params.id);
    
    if (!chat) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found',
      });
    }
    
    if (!chat.isParticipant(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to send messages to this chat',
      });
    }
    
    // Добавляем сообщение
    await chat.addMessage(req.user._id, text);
    
    // Загружаем информацию об отправителе
    const message = chat.messages[chat.messages.length - 1];
    await message.populate('senderId', 'firstName lastName displayName avatarUrl');
    
    res.status(201).json({
      success: true,
      data: message,
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Отметить сообщения как прочитанные
router.post('/:id/read', auth, async (req, res) => {
  try {
    const chat = await Chat.findById(req.params.id);
    
    if (!chat) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found',
      });
    }
    
    if (!chat.isParticipant(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this chat',
      });
    }
    
    await chat.markAsRead(req.user._id);
    
    res.json({
      success: true,
      message: 'Messages marked as read',
    });
  } catch (error) {
    console.error('Mark as read error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router; 