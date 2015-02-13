mongoClient = require('mongodb').MongoClient
format = require('util').format;

dbConfig = 
  "dbuser"     : ""
  "dbpassword" : ""

exports.setDbConfig = (dbuser, dbpassword) ->
  dbConfig.dbuser = dbuser
  dbConfig.dbpassword = dbpassword
  return

exports.checkIfAlreadyRegistered = (email, callback) ->
  mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
    if err
     throw err

    collection = db.collection 'useraccountdetails'
    collection.find({"email": email}).toArray (err, results) ->
      db.close()
      if results.length > 0
        callback true
      else callback false
      return
    return

exports.addNewUser = (requestingUser, callback) ->
  mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
    user = 
      "firstName"     : ""
      "lastName"      : ""
      "username"       : ""
      "email"          : ""
      "signinStatus"  : false
      "siginPage"     : "/signin"
      "dashboardPage" : ""
      "status"         : "Sign in"
      "toggle"         : ""
    

    if err
      callback user

    collection = db.collection 'useraccountdetails'
    
    collection.insert requestingUser, (err, docs) ->
      db.close()
      if !err
        user = 
          "firstName"     : docs[0]["firstName"]
          "lastName"      : docs[0]["lastName"]
          "username"       : docs[0]["username"]
          "email"          : docs[0]["email"]
          "signinStatus"  : true
          "siginPage"     : ""
          "dashboardPage" : "/dashboard"
          "status"         : docs[0]["username"]
          "toggle"         : "dropdown"
      
      console.log user
      callback user
      return
    return
  return

exports.authenticateUserCredentials  = (email, password, callback) ->
  console.log "authenticating user+++"
  mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
    console.log "authenticating user===="
    user = 
      "firstName"     : ""
      "lastName"      : ""
      "username"      : ""
      "email"         : ""
      "signinStatus"  : false
      "siginPage"     : "/signin"
      "dashboardPage" : ""
      "status"        : "Sign in"
      "toggle"        : ""
    
    if err
     callback user

    console.log "email", email
     

    collection = db.collection 'useraccountdetails'
    
    collection.find({"email": email}).toArray (err, results) ->
      db.close()
      if !err and results.length > 0 and results[0].password == password
        user = 
          "firstName"     : results[0]["firstName"]
          "lastName"      : results[0]["lastName"]
          "username"      : results[0]["username"]
          "email"         : results[0]["email"]
          "signinStatus"  : true
          "siginPage"     : ""
          "dashboardPage" : "/dashboard"
          "status"        : results[0]["username"]
          "toggle"        : "dropdown"

      callback user
          
      return
    return  

