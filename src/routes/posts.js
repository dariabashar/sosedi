const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { upload, handleUploadError } = require('../middleware/upload');
const Post = require('../models/Post');

// Получить посты поблизости
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
    const posts = await Post.findNearby(coordinates, parseInt(radius), parseInt(limit));
    
    res.json({
      success: true,
      data: posts,
    });
  } catch (error) {
    console.error('Get posts error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Создать новый пост
router.post('/', auth, upload.single('image'), handleUploadError, async (req, res) => {
  try {
    const { text, latitude, longitude } = req.body;
    
    if (!text || !latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Text, latitude, and longitude are required',
      });
    }
    
    const postData = {
      authorId: req.user._id,
      authorName: req.user.fullName,
      authorAddress: req.user.address,
      text,
      location: {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)],
      },
    };
    
    if (req.file) {
      postData.imagePath = `/uploads/${req.file.filename}`;
    }
    
    const post = new Post(postData);
    await post.save();
    
    res.status(201).json({
      success: true,
      data: post,
    });
  } catch (error) {
    console.error('Create post error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Получить конкретный пост
router.get('/:id', auth, async (req, res) => {
  try {
    const post = await Post.findById(req.params.id)
      .populate('authorId', 'firstName lastName displayName avatarUrl')
      .populate('likedBy', 'firstName lastName displayName');
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }
    
    res.json({
      success: true,
      data: post,
    });
  } catch (error) {
    console.error('Get post error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Обновить пост
router.put('/:id', auth, async (req, res) => {
  try {
    const { text } = req.body;
    
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }
    
    if (post.authorId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this post',
      });
    }
    
    post.text = text;
    post.updatedAt = new Date();
    await post.save();
    
    res.json({
      success: true,
      data: post,
    });
  } catch (error) {
    console.error('Update post error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Удалить пост
router.delete('/:id', auth, async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }
    
    if (post.authorId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this post',
      });
    }
    
    post.isDeleted = true;
    post.updatedAt = new Date();
    await post.save();
    
    res.json({
      success: true,
      message: 'Post deleted successfully',
    });
  } catch (error) {
    console.error('Delete post error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Лайкнуть/убрать лайк с поста
router.post('/:id/like', auth, async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }
    
    const userId = req.user._id;
    const isLiked = post.likedBy.includes(userId);
    
    if (isLiked) {
      post.likedBy = post.likedBy.filter(id => id.toString() !== userId.toString());
    } else {
      post.likedBy.push(userId);
    }
    
    await post.save();
    
    res.json({
      success: true,
      data: {
        isLiked: !isLiked,
        likesCount: post.likedBy.length,
      },
    });
  } catch (error) {
    console.error('Like post error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// Добавить комментарий к посту
router.post('/:id/comments', auth, async (req, res) => {
  try {
    const { text } = req.body;
    
    if (!text) {
      return res.status(400).json({
        success: false,
        message: 'Comment text is required',
      });
    }
    
    const post = await Post.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found',
      });
    }
    
    const comment = {
      authorId: req.user._id,
      authorName: req.user.fullName,
      text,
      createdAt: new Date(),
    };
    
    post.comments.push(comment);
    await post.save();
    
    res.status(201).json({
      success: true,
      data: comment,
    });
  } catch (error) {
    console.error('Add comment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router; 