const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Group = require('../models/Group');

// Получить группы поблизости
router.get('/', auth, async (req, res) => {
  try {
    const { lat, lng, radius = 1000, limit = 20 } = req.query;
    
    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required',
      });
    }
    
    const coordinates = [parseFloat(lng), parseFloat(lat)];
    const groups = await Group.findNearby(coordinates, parseInt(radius), parseInt(limit));
    
    // Добавляем информацию о том, является ли пользователь участником
    const groupsWithMembership = groups.map(group => ({
      ...group.toObject(),
      isMyGroup: group.isMember(req.user._id),
    }));
    
    res.json({
      success: true,
      data: groupsWithMembership,
    });
  } catch (error) {
    console.error('Get groups error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Создать новую группу
router.post('/', auth, async (req, res) => {
  try {
    const { name, description, latitude, longitude, isPrivate = false, maxDistance = 1000 } = req.body;
    
    if (!name || !description || !latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Name, description, latitude, and longitude are required',
      });
    }
    
    const groupData = {
      name,
      description,
      authorId: req.user._id,
      authorName: req.user.fullName,
      authorAddress: req.user.address,
      location: {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)],
      },
      isPrivate,
      maxDistance: parseInt(maxDistance),
      members: [{ userId: req.user._id }], // Автор автоматически становится участником
    };
    
    const group = new Group(groupData);
    await group.save();
    
    res.status(201).json({
      success: true,
      data: group,
    });
  } catch (error) {
    console.error('Create group error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Получить конкретную группу
router.get('/:id', auth, async (req, res) => {
  try {
    const group = await Group.findById(req.params.id)
      .populate('authorId', 'firstName lastName displayName avatarUrl')
      .populate('members.userId', 'firstName lastName displayName avatarUrl');
    
    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found',
      });
    }
    
    const groupData = group.toObject();
    groupData.isMyGroup = group.isMember(req.user._id);
    
    res.json({
      success: true,
      data: groupData,
    });
  } catch (error) {
    console.error('Get group error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Присоединиться к группе
router.post('/:id/join', auth, async (req, res) => {
  try {
    const group = await Group.findById(req.params.id);
    
    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found',
      });
    }
    
    if (group.isMember(req.user._id)) {
      return res.status(400).json({
        success: false,
        message: 'Already a member of this group',
      });
    }
    
    await group.addMember(req.user._id);
    
    res.json({
      success: true,
      message: 'Successfully joined the group',
    });
  } catch (error) {
    console.error('Join group error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Покинуть группу
router.post('/:id/leave', auth, async (req, res) => {
  try {
    const group = await Group.findById(req.params.id);
    
    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found',
      });
    }
    
    if (!group.isMember(req.user._id)) {
      return res.status(400).json({
        success: false,
        message: 'Not a member of this group',
      });
    }
    
    await group.removeMember(req.user._id);
    
    res.json({
      success: true,
      message: 'Successfully left the group',
    });
  } catch (error) {
    console.error('Leave group error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router; 