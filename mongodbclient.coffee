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

exports.authenticateUserCredentials  = (username, password, callback) ->
  mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
    if err
     callback
        "username" : ""
        "password" : ""

    collection = db.collection 'useraccountdetails'
    
    collection.find(username).toArray (err, results) ->
      db.close()
      if results.length == 1 and results[0].password == password
        callback
          "username" : results[0].username
          "password" : results[0].password

      return
    return  

