// Generated by CoffeeScript 1.8.0
(function() {
  var dbConfig, format, mongoClient;

  mongoClient = require('mongodb').MongoClient;

  format = require('util').format;

  dbConfig = {
    "dbuser": "",
    "dbpassword": ""
  };

  exports.setDbConfig = function(dbuser, dbpassword) {
    dbConfig.dbuser = dbuser;
    dbConfig.dbpassword = dbpassword;
  };

  exports.checkIfUsernameAvailable = function(username, callback) {
    return mongoClient.connect("mongodb://" + dbConfig.dbuser + ":" + dbConfig.dbpassword + "@ds029640.mongolab.com:29640/tvserieswebappdatabase", function(err, db) {
      var collection;
      if (err) {
        throw err;
      }
      collection = db.collection('useraccountdetails');
      collection.find({
        "username": "knayamlohani"
      }).toArray(function(err, results) {
        if (results.length > 0) {
          callback("false");
        } else {
          callback("true");
        }
        db.close();
      });
    });
  };

  exports.addNewUser = function(user, callback) {
    mongoClient.connect("mongodb://" + dbConfig.dbuser + ":" + dbConfig.dbpassword + "@ds029640.mongolab.com:29640/tvserieswebappdatabase", function(err, db) {
      var collection;
      if (err) {
        console.log(err);
        callback({
          "username": "",
          "password": ""
        });
      }
      collection = db.collection('useraccountdetails');
      collection.insert(user, function(err, docs) {
        user = docs[0];
        console.log(user);
        db.close();
        callback(user);
      });
    });
  };

  exports.authenticateUserCredentials = function(username, password, callback) {
    return mongoClient.connect("mongodb://" + dbConfig.dbuser + ":" + dbConfig.dbpassword + "@ds029640.mongolab.com:29640/tvserieswebappdatabase", function(err, db) {
      var collection;
      if (err) {
        callback({
          "username": "",
          "password": ""
        });
      }
      collection = db.collection('useraccountdetails');
      collection.find(username).toArray(function(err, results) {
        db.close();
        if (results.length === 1 && results[0].password === password) {
          callback({
            "username": results[0].username,
            "password": results[0].password
          });
        }
      });
    });
  };

}).call(this);


//# sourceMappingURL=mongodbclient.js.map
