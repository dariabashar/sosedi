const User = require('../models/User');
const { admin } = require('../config/firebase');

// Получить профиль текущего пользователя
const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id)
      .select('-__v');
    
    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// Обновить профиль пользователя
const updateProfile = async (req, res) => {
  try {
    const { firstName, lastName, displayName, address, latitude, longitude } = req.body;
    
    const updateData = {};
    if (firstName !== undefined) updateData.firstName = firstName;
    if (lastName !== undefined) updateData.lastName = lastName;
    if (displayName !== undefined) updateData.displayName = displayName;
    if (address !== undefined) updateData.address = address;
    
    // Обновляем геолокацию, если предоставлены координаты
    if (latitude !== undefined && longitude !== undefined) {
      updateData.location = {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)],
      };
    }
    
    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    ).select('-__v');
    
    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// Создать или обновить пользователя после Firebase аутентификации
const createOrUpdateUser = async (req, res) => {
  try {
    const { phoneNumber, firstName, lastName, displayName, address, latitude, longitude } = req.body;
    
    // Проверяем, существует ли пользователь
    let user = await User.findOne({ firebaseUid: req.user.firebaseUid });
    
    if (user) {
      // Обновляем существующего пользователя
      const updateData = {};
      if (phoneNumber) updateData.phoneNumber = phoneNumber;
      if (firstName) updateData.firstName = firstName;
      if (lastName) updateData.lastName = lastName;
      if (displayName) updateData.displayName = displayName;
      if (address) updateData.address = address;
      
      if (latitude && longitude) {
        updateData.location = {
          type: 'Point',
          coordinates: [parseFloat(longitude), parseFloat(latitude)],
        };
      }
      
      user = await User.findByIdAndUpdate(
        user._id,
        updateData,
        { new: true, runValidators: true }
      ).select('-__v');
    } else {
      // Создаем нового пользователя
      const userData = {
        firebaseUid: req.user.firebaseUid,
        phoneNumber,
        firstName,
        lastName,
        displayName,
        address,
        location: {
          type: 'Point',
          coordinates: [parseFloat(longitude), parseFloat(latitude)],
        },
      };
      
      user = new User(userData);
      await user.save();
      user = user.toObject();
      delete user.__v;
    }
    
    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error('Create/Update user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// Получить пользователей поблизости
const getNearbyUsers = async (req, res) => {
  try {
    const { lat, lng, radius = 500 } = req.query;
    
    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required',
      });
    }
    
    const coordinates = [parseFloat(lng), parseFloat(lat)];
    const users = await User.findNearby(coordinates, parseInt(radius));
    
    res.json({
      success: true,
      data: users,
    });
  } catch (error) {
    console.error('Get nearby users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// Удалить пользователя (мягкое удаление)
const deleteUser = async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.user._id, {
      isDeleted: true,
      updatedAt: new Date(),
    });
    
    res.json({
      success: true,
      message: 'User deleted successfully',
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

module.exports = {
  getProfile,
  updateProfile,
  createOrUpdateUser,
  getNearbyUsers,
  deleteUser,
}; 