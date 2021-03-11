const express = require('express');
const mongoose = require('mongoose');
const path = require('path');
const config = require('config');

const app = express();

app.use(express.json());

const db = config.get('mongoURI');

const Session = require('./models/Session');

// mongoose.connect("mongodb://localhost/newBB")
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

//FETCH sessions
app.get('/fetch', (req, res) => {
  Session.find({}).then((items) => {
    res.send(items)
  })
  //(if only want emplyees in bracket {})
})

// CREATE a new entry
app.post('/add', (req, res) => {
    var newSession = new Session({
      id: req.get("id"),
      startTime: req.get("startTime"),
      duration: req.get("duration"),
      // dateOfEntry: req.body.dateOfEntry || Date.now()
    });
    newSession.save().then(() => {
      if (newSession.isNew = false) {
        console.log("Saved session data!")
        res.send("Saved session data!")
      } else {
        console.log("Failed to save data")
      }
    });
  });



// DELETE entry
// post request
// app.post("/delete", (req, res) => {
//   Session.findOneAndDelete({
//     _id: req.get("_id")
//   }, (err) => {
//     console.log("Failed" + err)
//   })
//   res.send("Deleted!")
// })
app.delete('/:id', (req, res) => {
  Session.findOneAndDelete({_id: req.params.id})
    .then(() => res.json({sucess: true}))
    .catch(err => res.status(404).json({ sucess: false}));
  })
 
//Updating note
//Post
app.post('/update', (req, res) => {
  Session.findOneAndUpdate({
    _id: req.get("_id")
  }, {
    id: req.get("id"),
    startTime: req.get("startTime"),
    duration: req.get("duration")
  }, (err) => {
    console.log("Failed to updat " + err)
  })
  res.send("Updated!")
})

const port = 5000;



app.listen(port, () => console.log(`Server started on port: http://localhost:${port}`));

