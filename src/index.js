/** Default to development environment. */
process.env.NODE_ENV = process.env.NODE_ENV || "development";

/** Modules */
var express  = require('express');
var config   = require('config');
var mongoose = require('mongoose');
var redis    = require('redis');
var util     = require('util');

/** Init. express. */
var app = express();

/** Set app properties. */
app.set('port', process.env.APP_PORT || config.get('app.port'));
app.set('redis_host', process.env.REDIS_PORT_6379_TCP_ADDR || config.get('redis.host'));
app.set('redis_port', process.env.REDIS_PORT_6379_TCP_PORT || config.get('redis.port'));
app.set('redis_options', config.get('redis.options'));
app.set('mongo_host', process.env.MONGO_PORT_27017_TCP_ADDR || config.get('mongo.host'));
app.set('mongo_port', process.env.MONGO_PORT_27017_TCP_PORT || config.get('mongo.port'));
app.set('mongo_db', config.get('mongo.db'));
app.set('mongo_options', config.get('mongo.options'));

/** Test mongo connection. Will throw if unable to connect. */
mongoose.connect(
  util.format(
    'mongodb://%s/%s:%d',
    app.get('mongo_host'),
    app.get('mongo_db'),
    app.get('mongo_port')
  ),
  app.get('mongo_options')
);

/** Test redis connection. */
var redisClient = redis.createClient(
  app.get('redis_port'),
  app.get('redis_host'),
  app.get('redis_options')
);

redisClient.set('someredisprop', 'OK');

redisClient.get('someredisprop', function (err, val) {
  console.log('If this says "OK" then redis is working: %s', val.toString());
});

/** Fire up express. */
app.get('/', function (req, res) {
  res.send('Hello world\n');
});

var server = app.listen(app.get('port'), function() {
  console.log(
    'Example app listening at http://localhost:%s in a %s enviornment.',
    app.get('port'),
    app.get('env')
  );
});
