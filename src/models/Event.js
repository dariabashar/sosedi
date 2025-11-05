const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    trim: true,
  },
  date: {
    type: Date,
    required: true,
  },
  location: {
    type: String,
    required: true,
    trim: true,
  },
  coordinates: {
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
  authorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  authorName: {
    type: String,
    required: true,
  },
  imageUrl: {
    type: String,
  },
  videoUrl: {
    type: String,
  },
  participants: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    joinedAt: {
      type: Date,
      default: Date.now,
    },
  }],
  maxParticipants: {
    type: Number,
  },
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
eventSchema.index({ coordinates: '2dsphere' });
eventSchema.index({ date: 1 });
eventSchema.index({ createdAt: -1 });
eventSchema.index({ isActive: 1 });

// Виртуальные поля
eventSchema.virtual('participantCount').get(function() {
  return this.participants.length;
});

eventSchema.virtual('isFull').get(function() {
  if (!this.maxParticipants) return false;
  return this.participants.length >= this.maxParticipants;
});

// Метод для поиска событий в радиусе
eventSchema.statics.findNearby = function(coordinates, maxDistance = 500, limit = 20) {
  return this.find({
    coordinates: {
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
    date: { $gte: new Date() }, // Только будущие события
  })
  .sort({ date: 1 })
  .limit(limit)
  .populate('authorId', 'firstName lastName displayName avatarUrl');
};

// Метод для проверки участия пользователя
eventSchema.methods.isParticipant = function(userId) {
  return this.participants.some(participant => 
    participant.userId.toString() === userId.toString()
  );
};

// Метод для добавления участника
eventSchema.methods.addParticipant = function(userId) {
  if (this.isFull) {
    throw new Error('Event is full');
  }
  
  if (!this.isParticipant(userId)) {
    this.participants.push({ userId });
    return this.save();
  }
  return Promise.resolve(this);
};

// Метод для удаления участника
eventSchema.methods.removeParticipant = function(userId) {
  this.participants = this.participants.filter(participant => 
    participant.userId.toString() !== userId.toString()
  );
  return this.save();
};

module.exports = mongoose.model('Event', eventSchema); 