const { admin } = require('../config/firebase');
const User = require('../models/User');

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ message: 'No token provided' });
    }

    // Верифицируем токен через Firebase
    const decodedToken = await admin.auth().verifyIdToken(token);
    
    // Находим пользователя в базе данных
    const user = await User.findOne({ 
      firebaseUid: decodedToken.uid,
      isDeleted: false 
    });

    if (!user) {
      return res.status(401).json({ message: 'User not found' });
    }

    req.user = user;
    req.token = token;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(401).json({ message: 'Please authenticate' });
  }
};

module.exports = auth; 