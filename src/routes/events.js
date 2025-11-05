const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Event = require('../models/Event');

// Получить события поблизости
router.get('/', auth, async (req, res) => {
  try {
    const { lat, lng, radius = 500, limit = 20 } = req.query;
    
    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required',
      });
    }
    
    const coordinates = [parseFloat(lng), parseFloat(lat)];
    const events = await Event.findNearby(coordinates, parseInt(radius), parseInt(limit));
    
    // Добавляем информацию о том, участвует ли пользователь
    const eventsWithParticipation = events.map(event => ({
      ...event.toObject(),
      isParticipant: event.isParticipant(req.user._id),
    }));
    
    res.json({
      success: true,
      data: eventsWithParticipation,
    });
  } catch (error) {
    console.error('Get events error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Создать новое событие
router.post('/', auth, async (req, res) => {
  try {
    const { title, description, date, location, latitude, longitude, maxParticipants, imageUrl, videoUrl } = req.body;
    
    if (!title || !date || !location || !latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Title, date, location, latitude, and longitude are required',
      });
    }
    
    const eventData = {
      title,
      description,
      date: new Date(date),
      location,
      coordinates: {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)],
      },
      authorId: req.user._id,
      authorName: req.user.fullName,
      participants: [{ userId: req.user._id }], // Автор автоматически становится участником
    };
    
    if (maxParticipants) eventData.maxParticipants = parseInt(maxParticipants);
    if (imageUrl) eventData.imageUrl = imageUrl;
    if (videoUrl) eventData.videoUrl = videoUrl;
    
    const event = new Event(eventData);
    await event.save();
    
    res.status(201).json({
      success: true,
      data: event,
    });
  } catch (error) {
    console.error('Create event error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Получить конкретное событие
router.get('/:id', auth, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id)
      .populate('authorId', 'firstName lastName displayName avatarUrl')
      .populate('participants.userId', 'firstName lastName displayName avatarUrl');
    
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }
    
    const eventData = event.toObject();
    eventData.isParticipant = event.isParticipant(req.user._id);
    
    res.json({
      success: true,
      data: eventData,
    });
  } catch (error) {
    console.error('Get event error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Присоединиться к событию
router.post('/:id/join', auth, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }
    
    if (event.isParticipant(req.user._id)) {
      return res.status(400).json({
        success: false,
        message: 'Already participating in this event',
      });
    }
    
    await event.addParticipant(req.user._id);
    
    res.json({
      success: true,
      message: 'Successfully joined the event',
    });
  } catch (error) {
    console.error('Join event error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// Покинуть событие
router.post('/:id/leave', auth, async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);
    
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found',
      });
    }
    
    if (!event.isParticipant(req.user._id)) {
      return res.status(400).json({
        success: false,
        message: 'Not participating in this event',
      });
    }
    
    await event.removeParticipant(req.user._id);
    
    res.json({
      success: true,
      message: 'Successfully left the event',
    });
  } catch (error) {
    console.error('Leave event error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router; 