const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema({
  authorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  authorName: {
    type: String,
    required: true,
  },
  text: {
    type: String,
    required: true,
    trim: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

const postSchema = new mongoose.Schema({
  authorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  authorName: {
    type: String,
    required: true,
  },
  authorAddress: {
    type: String,
    required: true,
  },
  text: {
    type: String,
    required: true,
    trim: true,
  },
  imagePath: {
    type: String,
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number],
      required: true,
    },
  },
  likedBy: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  comments: [commentSchema],
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

// Индекс для геопространственных запросов
postSchema.index({ location: '2dsphere' });
postSchema.index({ createdAt: -1 });

// Виртуальные поля
postSchema.virtual('likesCount').get(function() {
  return this.likedBy.length;
});

postSchema.virtual('commentsCount').get(function() {
  return this.comments.length;
});

// Метод для поиска постов в радиусе
postSchema.statics.findNearby = function(coordinates, maxDistance = 500, limit = 20) {
  return this.find({
    location: {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: coordinates,
        },
        $maxDistance: maxDistance,
      },
    },
    isDeleted: false,
  })
  .sort({ createdAt: -1 })
  .limit(limit)
  .populate('authorId', 'firstName lastName displayName avatarUrl');
};

module.exports = mongoose.model('Post', postSchema); 