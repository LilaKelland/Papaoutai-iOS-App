const express = require('express');
const mongoose = require('mongoose');
const config = require('config');

const app = express();

const db = config.get('mongoURI');
const Session = require('./models/Session');

mongoose
  .connect(db, { useNewUrlParser: true, useCreateIndex: true, useFindAndModify: false })
  .then(() => console.log('MongoDB Connected...'))
  .catch(err => console.log(err));

// Read all entries
app.get('/', (req, res) => {
    Session.find()
        .sort({date: -1})
        .then(items => console.log(res.json(items)));
});

// Add a new entry
app.post('/', (req, res) => {
    const newSession = new Session({
      id: req.body.id,
      startTime: req.body.startTime || 95156464,
      duration: req.body.duration,
      dateOfEntry: req.body.dateOfEntry || Date.now()
    });
    newSession
      .save()
      .then(item => res.json(item));
  });


// Session
//     .findOneAndUpdate(
//       { _id: '603fd34af1143a5530c26152'},
//       { duration: 100 }
//     )
//     .then(item => console.log(item));

// Delete an entry
app.delete('/:id', (req, res) => {
    Animal.findOneAndDelete({ _id: req.params.id })
      .then(() => res.json({ success: true }))
      .catch(err => res.status(404).json({ success: false }));
  });

  // Update an entryn
app.put('/:id', (req, res) => {
    Animal.findOneAndUpdate({ _id: req.params.id }, req.body)
      .then(() => res.json({ success: true }))
      .catch(err => res.status(404).json({ success: false }));
  });

// Session
//     .findOneAndDelete(
//       { _id: '603fd34af1143a5530c26152'},
//       { duration: 100 }
//     )
//     .then(item => console.log('item deleted'));

// const newSession = new Session({
//     id: 123,
//     startTime: 95156464,
//     duration: 2000,
//     dateOfEntry: Date.now()
//   })

// newSession
//   .save()
//   .then(item => console.log(item))
//   .catch(err => console.log(err));



const port = 5000;
// app.use(express.json());

app.use(express.json());

app.listen(port, () => console.log(`Server started on port: http://localhost:${port}`));

