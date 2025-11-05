const mongoose = require('mongoose');

const groupPostSchema = new mongoose.Schema({
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
  imagePath: {
    type: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

const groupSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
    trim: true,
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
  members: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    joinedAt: {
      type: Date,
      default: Date.now,
    },
  }],
  posts: [groupPostSchema],
  isPrivate: {
    type: Boolean,
    default: false,
  },
  maxDistance: {
    type: Number,
    default: 1000, // 1 км по умолчанию
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
groupSchema.index({ location: '2dsphere' });
groupSchema.index({ createdAt: -1 });

// Виртуальные поля
groupSchema.virtual('memberCount').get(function() {
  return this.members.length;
});

// Метод для поиска групп в радиусе
groupSchema.statics.findNearby = function(coordinates, maxDistance = 1000, limit = 20) {
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

// Метод для проверки, является ли пользователь участником группы
groupSchema.methods.isMember = function(userId) {
  return this.members.some(member => member.userId.toString() === userId.toString());
};

// Метод для добавления участника
groupSchema.methods.addMember = function(userId) {
  if (!this.isMember(userId)) {
    this.members.push({ userId });
    return this.save();
  }
  return Promise.resolve(this);
};

// Метод для удаления участника
groupSchema.methods.removeMember = function(userId) {
  this.members = this.members.filter(member => member.userId.toString() !== userId.toString());
  return this.save();
};

module.exports = mongoose.model('Group', groupSchema); 