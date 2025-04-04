// var express = require('express');
// var app = express();
// var uuid = require('node-uuid');

// var pg = require('pg');
// var conString = process.env.DB; // "postgres://username:password@localhost/database";

// // Routes
// app.get('/api/status', function(req, res) {
//   pg.connect(conString, function(err, client, done) {
//     if(err) {
//       return res.status(500).send('error fetching client from pool');
//     }
//     client.query('SELECT now() as time', [], function(err, result) {
//       //call `done()` to release the client back to the pool
//       done();

//       if(err) {
//         return res.status(500).send('error running query');
//       }

//       return res.json({
//         request_uuid: uuid.v4(),
//         time: result.rows[0].time
//       });
//     });
//   });
// });

// // catch 404 and forward to error handler
// app.use(function(req, res, next) {
//   var err = new Error('Not Found');
//   err.status = 404;
//   next(err);
// });

// // error handlers

// // development error handler
// // will print stacktrace
// if (app.get('env') === 'development') {
//   app.use(function(err, req, res, next) {
//     res.status(err.status || 500);
//     res.json({
//       message: err.message,
//       error: err
//     });
//   });
// }

// // production error handler
// // no stacktraces leaked to user
// app.use(function(err, req, res, next) {
//   res.status(err.status || 500);
//   res.json({
//     message: err.message,
//     error: {}
//   });
// });

// Updated code
// module.exports = app;
var express = require('express');
var app = express();
const { v4: uuidv4 } = require('uuid');
const { Pool } = require('pg');

// PostgreSQL connection
const pool = new Pool({
    connectionString: process.env.DB
});

// API Route
app.get('/api/status', async (req, res) => {
    try {
        const result = await pool.query('SELECT now() as time');
        res.json({ request_uuid: uuidv4(), time: result.rows[0].time });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error running query', details: err.message });
    }
});

// Catch 404 and forward to error handler
app.use((req, res, next) => {
    const err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// Error handlers
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(err.status || 500).json({
        message: err.message,
        error: process.env.NODE_ENV === 'development' ? err : {},
    });
});

module.exports = app;
