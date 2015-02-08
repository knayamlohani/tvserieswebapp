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

  exports.checkIfAlreadyRegistered = function(email, callback) {
    return mongoClient.connect("mongodb://" + dbConfig.dbuser + ":" + dbConfig.dbpassword + "@ds029640.mongolab.com:29640/tvserieswebappdatabase", function(err, db) {
      var collection;
      if (err) {
        throw err;
      }
      collection = db.collection('useraccountdetails');
      collection.find({
        "email": email
      }).toArray(function(err, results) {
        db.close();
        if (results.length > 0) {
          callback(false);
        } else {
          callback(true);
        }
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

  exports.authenticateUserCredentials = function(email, password, callback) {
    return mongoClient.connect("mongodb://" + dbConfig.dbuser + ":" + dbConfig.dbpassword + "@ds029640.mongolab.com:29640/tvserieswebappdatabase", function(err, db) {
      var collection;
      if (err) {
        callback({
          "username": "",
          "email": "",
          "first-name": "",
          "last-name": "",
          "signin-status": flase
        });
      }
      collection = db.collection('useraccountdetails');
      collection.find({
        "email": email
      }).toArray(function(err, results) {
        db.close();
        if (results.length === 1 && results[0].password === password) {
          callback({
            "username": results[0].username,
            "email": results[0].email,
            "first-name": results[0]["first-name"],
            "last-name": results[0]["last-name"],
            "signin-status": true
          });
        } else {
          callback({
            "username": "",
            "email": "",
            "first-name": "",
            "last-name": "",
            "signin-status": flase
          });
        }
      });
    });
  };

}).call(this);


//# sourceMappingURL=mongodbclient.js.map
