const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { upload, handleUploadError } = require('../middleware/upload');
const Advertisement = require('../models/Advertisement');

// Получить объявления поблизости
router.get('/', auth, async (req, res) => {
  try {
    const { lat, lng, radius = 500, type, limit = 20 } = req.query;
    
    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required',
      });
    }
    
    const coordinates = [parseFloat(lng), parseFloat(lat)];
    const filters = {};
    if (type) filters.type = type;
    
    const advertisements = await Advertisement.findNearby(coordinates, parseInt(radius), filters, parseInt(limit));
    
    // Добавляем информацию о том, заинтересован ли пользователь
    const adsWithInterest = advertisements.map(ad => ({
      ...ad.toObject(),
      isInterested: ad.isInterested(req.user._id),
    }));
    
    res.json({
      success: true,
      data: adsWithInterest,
    });
  } catch (error) {
    console.error('Get advertisements error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Создать новое объявление
router.post('/', auth, upload.single('image'), handleUploadError, async (req, res) => {
  try {
    const { title, description, type, price, latitude, longitude } = req.body;
    
    if (!title || !description || !type || !latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Title, description, type, latitude, and longitude are required',
      });
    }
    
    if (type === 'sale' && !price) {
      return res.status(400).json({
        success: false,
        message: 'Price is required for sale advertisements',
      });
    }
    
    const adData = {
      title,
      description,
      type,
      authorId: req.user._id,
      authorName: req.user.fullName,
      authorAddress: req.user.address,
      location: {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)],
      },
    };
    
    if (price) adData.price = price;
    if (req.file) adData.imagePath = `/uploads/${req.file.filename}`;
    
    const advertisement = new Advertisement(adData);
    await advertisement.save();
    
    res.status(201).json({
      success: true,
      data: advertisement,
    });
  } catch (error) {
    console.error('Create advertisement error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Получить конкретное объявление
router.get('/:id', auth, async (req, res) => {
  try {
    const advertisement = await Advertisement.findById(req.params.id)
      .populate('authorId', 'firstName lastName displayName avatarUrl')
      .populate('interestedUsers.userId', 'firstName lastName displayName');
    
    if (!advertisement) {
      return res.status(404).json({
        success: false,
        message: 'Advertisement not found',
      });
    }
    
    const adData = advertisement.toObject();
    adData.isInterested = advertisement.isInterested(req.user._id);
    
    res.json({
      success: true,
      data: adData,
    });
  } catch (error) {
    console.error('Get advertisement error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Обновить объявление
router.put('/:id', auth, async (req, res) => {
  try {
    const { title, description, price, isActive } = req.body;
    
    const advertisement = await Advertisement.findById(req.params.id);
    
    if (!advertisement) {
      return res.status(404).json({
        success: false,
        message: 'Advertisement not found',
      });
    }
    
    if (advertisement.authorId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this advertisement',
      });
    }
    
    if (title !== undefined) advertisement.title = title;
    if (description !== undefined) advertisement.description = description;
    if (price !== undefined) advertisement.price = price;
    if (isActive !== undefined) advertisement.isActive = isActive;
    
    advertisement.updatedAt = new Date();
    await advertisement.save();
    
    res.json({
      success: true,
      data: advertisement,
    });
  } catch (error) {
    console.error('Update advertisement error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Удалить объявление
router.delete('/:id', auth, async (req, res) => {
  try {
    const advertisement = await Advertisement.findById(req.params.id);
    
    if (!advertisement) {
      return res.status(404).json({
        success: false,
        message: 'Advertisement not found',
      });
    }
    
    if (advertisement.authorId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this advertisement',
      });
    }
    
    advertisement.isDeleted = true;
    advertisement.updatedAt = new Date();
    await advertisement.save();
    
    res.json({
      success: true,
      message: 'Advertisement deleted successfully',
    });
  } catch (error) {
    console.error('Delete advertisement error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Показать интерес к объявлению
router.post('/:id/interest', auth, async (req, res) => {
  try {
    const advertisement = await Advertisement.findById(req.params.id);
    
    if (!advertisement) {
      return res.status(404).json({
        success: false,
        message: 'Advertisement not found',
      });
    }
    
    const userId = req.user._id;
    const isInterested = advertisement.isInterested(userId);
    
    if (isInterested) {
      await advertisement.removeInterestedUser(userId);
    } else {
      await advertisement.addInterestedUser(userId);
    }
    
    res.json({
      success: true,
      data: {
        isInterested: !isInterested,
        interestedCount: advertisement.interestedUsers.length,
      },
    });
  } catch (error) {
    console.error('Interest advertisement error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router; 