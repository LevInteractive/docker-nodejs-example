var express = require('express');

var PORT = process.env.APP_PORT;

var app = express();

app.get('/', function (req, res) {
  res.send('Hello world\n');
});

app.listen(PORT);

console.log('Running on http://localhost:' + PORT + ' and the node env is: ' + process.env.NODE_ENV);
