const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { upload, handleUploadError } = require('../middleware/upload');
const {
  getProfile,
  updateProfile,
  createOrUpdateUser,
  getNearbyUsers,
  deleteUser,
} = require('../controllers/userController');

// Получить профиль текущего пользователя
router.get('/profile', auth, getProfile);

// Обновить профиль пользователя
router.put('/profile', auth, updateProfile);

// Создать или обновить пользователя после Firebase аутентификации
router.post('/profile', auth, createOrUpdateUser);

// Получить пользователей поблизости
router.get('/nearby', auth, getNearbyUsers);

// Удалить пользователя
router.delete('/profile', auth, deleteUser);

// Загрузить аватар
router.post('/avatar', auth, upload.single('avatar'), handleUploadError, async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded',
      });
    }

    const avatarUrl = `/uploads/${req.file.filename}`;
    
    // Обновляем пользователя
    const User = require('../models/User');
    await User.findByIdAndUpdate(req.user._id, {
      avatarUrl,
      updatedAt: new Date(),
    });

    res.json({
      success: true,
      data: { avatarUrl },
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router; 