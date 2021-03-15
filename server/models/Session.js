const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const SessionSchema = new Schema({
  id: {
    type: Number,
    required: true
  },
  startTime: {
    type: Number,
    required: true
  },
  duration: {
      type: Number,
      required: true 
  // },
  // dateOfEntry: {
  //   type: Date,
  //   default: Date.now()
  }
});

module.exports = Item = mongoose.model('session', SessionSchema);