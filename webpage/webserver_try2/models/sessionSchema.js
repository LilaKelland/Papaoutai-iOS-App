const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const session = new Schema({
    id: Number, 
    startTime: Number,
    duration: Number
//   id: {
//     type: Number,
//     required: true
//   },
//   startTime: {
//     type: Number,
//     required: true
//   },
//   duration: {
//       type: Number,
//       required: true 
  // },
  // dateOfEntry: {
  //   type: Date,
  //   default: Date.now()
//   }
});

const Data = mongoose.model('Data', session);
module.exports = Data;