mongoClient = require('mongodb').MongoClient
format = require('util').format;

dbConfig = 
  "dbuser"     : ""
  "dbpassword" : ""

exports.setDbConfig = (dbuser, dbpassword) ->
  dbConfig.dbuser = dbuser
  dbConfig.dbpassword = dbpassword
  return

exports.checkIfUsernameAvailable = (username, callback) ->
  mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
    if err
     throw err

    collection = db.collection 'useraccountdetails'
    collection.find( {"username":"knayamlohani"}).toArray (err, results) ->
      if results.length > 0
        callback "false"
      else callback "true"
      db.close()
      return

    return

exports.addNewUser = (user, callback) ->
  mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
    if err
      console.log err
      callback
        "username" : ""
        "password" : ""
    collection = db.collection 'useraccountdetails'
    
    collection.insert user, (err, docs) ->
      user = docs[0]
      console.log user
      db.close()
      callback user

      return
    return
  return

exports.authenticateUserCredentials  = (email, password, callback) ->
  mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
    if err
     callback
        "username"      : ""
        "email"         : ""
        "first-name"    : ""
        "last-name"     : ""
        "signin-status" : flase

    collection = db.collection 'useraccountdetails'
    
    collection.find(email).toArray (err, results) ->
      db.close()
      if results.length == 1 and results[0].password == password
        callback
          "username"      : results[0].username
          "email"         : results[0].email
          "first-name"    : results[0]["first-name"]
          "last-name"     : results[0]["last-name"]
          "signin-status" : true

      return
    return  

