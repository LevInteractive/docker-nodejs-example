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
app.set('redis_host', config.get('redis.host'));
app.set('redis_port', config.get('redis.port'));
app.set('redis_options', config.get('redis.options'));
app.set('mongo_host', config.get('mongo.host'));
app.set('mongo_port', config.get('mongo.port'));
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

var Cat = mongoose.model('Cat', { name: String });

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
  var cats = ['Larry', 'Cinza', 'Steve', 'Jack', 'Foo', 'Poo', 'Krammer'];
  var kitty = new Cat({ name: cats[Math.floor(Math.random() * cats.length)] });
  kitty.save(function (err) {
    if (err) {
      throw err;
    }
    Cat.count(function(err, c) {
      if (err) {
        throw err;
      }
      res.send('Hello world, '+kitty.name+' was saved. Number of cats now in the system: '+c+'\n');
    });
  });
});

var server = app.listen(app.get('port'), function() {
  console.log(
    'App running on port %d in %s.',
    app.get('port'),
    app.get('env')
  );
});
