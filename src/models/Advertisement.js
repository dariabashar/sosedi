const mongoose = require('mongoose');

const advertisementSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
    trim: true,
  },
  type: {
    type: String,
    enum: ['sale', 'free'],
    required: true,
  },
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
  price: {
    type: String,
    required: function() {
      return this.type === 'sale';
    },
  },
  imagePath: {
    type: String,
  },
  interestedUsers: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    interestedAt: {
      type: Date,
      default: Date.now,
    },
  }],
  isActive: {
    type: Boolean,
    default: true,
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
advertisementSchema.index({ location: '2dsphere' });
advertisementSchema.index({ createdAt: -1 });
advertisementSchema.index({ type: 1 });
advertisementSchema.index({ isActive: 1 });

// Виртуальные поля
advertisementSchema.virtual('interestedCount').get(function() {
  return this.interestedUsers.length;
});

// Метод для поиска объявлений в радиусе
advertisementSchema.statics.findNearby = function(coordinates, maxDistance = 500, filters = {}, limit = 20) {
  const query = {
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
    isActive: true,
  };

  // Применяем фильтры
  if (filters.type) {
    query.type = filters.type;
  }

  return this.find(query)
    .sort({ createdAt: -1 })
    .limit(limit)
    .populate('authorId', 'firstName lastName displayName avatarUrl');
};

// Метод для проверки интереса пользователя
advertisementSchema.methods.isInterested = function(userId) {
  return this.interestedUsers.some(user => user.userId.toString() === userId.toString());
};

// Метод для добавления заинтересованного пользователя
advertisementSchema.methods.addInterestedUser = function(userId) {
  if (!this.isInterested(userId)) {
    this.interestedUsers.push({ userId });
    return this.save();
  }
  return Promise.resolve(this);
};

// Метод для удаления заинтересованного пользователя
advertisementSchema.methods.removeInterestedUser = function(userId) {
  this.interestedUsers = this.interestedUsers.filter(user => user.userId.toString() !== userId.toString());
  return this.save();
};

module.exports = mongoose.model('Advertisement', advertisementSchema); 