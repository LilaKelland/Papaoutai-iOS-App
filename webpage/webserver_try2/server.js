const express = require('express');
const mongoose = require('mongoose');
// const config = require('config');
var Data = require('./models/sessionSchema');

var app = express();


app.use(express.json());

// const db = config.get('mongoURI');

mongoose.connect("mongodb://localhost:27017/papaDB") //, {useFindAndModify: false})

// mongoose
//   .connect(db, { useNewUrlParser: true, useCreateIndex: true, useFindAndModify: false })
//   .then(() => console.log('MongoDB Connected...'))
//   .catch(err => console.log(err));

mongoose.connection.once("open", () => {
    console.log("connected to DB!")
}).on("error", (error) => {
    console.log("Failed to connect " + error)
})


// // Read all entries
// app.get('/', (req, res) => {
//     Session.find()
//         .sort({date: -1})
//         .then(items => console.log(res.json(items)));
// });

// //FETCH sessions
app.get('/fetch', (req, res) => {
  Data.find({}).then((items) => {
    res.send(items)
  })
  //(if only want emplyees in bracket {})
})

// CREATE a new entry
app.post('/add', (req, res) => {
    var session = new Data( {
      id: req.get("id"),
      startTime: req.get("startTime"),
      duration: req.get("duration"),
      // dateOfEntry: req.body.dateOfEntry || Date.now()
    });
    session.save(function(err, session) {
      if (!err) {
        console.log("Saved session data!")
        console.log(session)
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


// app.delete('/:id', (req, res) => {
//   Session.findOneAndDelete({_id: req.params.id})
//     .then(() => res.json({sucess: true}))
//     .catch(err => res.status(404).json({ sucess: false}));
//   })
 
// //Updating note
// //Post
// app.post('/update', (req, res) => {
//   Session.findOneAndUpdate({
//     _id: req.get("_id")
//   }, {
//     id: req.get("id"),
//     startTime: req.get("startTime"),
//     duration: req.get("duration")
//   }, (err) => {
//     console.log("Failed to updat " + err)
//   })
//   res.send("Updated!")
// })

// const port = 5000;

//http://192.168.4.29/5000
var server = app.listen(5000, "192.168.4.29", () => {
    console.log("Server is running")
});

// app.listen(port, () => console.log(`Server started on port: http://localhost:${port}`));

