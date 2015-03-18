mongoClient = require('mongodb').MongoClient
format = require('util').format;

dbConfig = 
  "dbuser"     : ""
  "dbpassword" : ""

exports.setDbConfig = (dbuser, dbpassword) ->
  dbConfig.dbuser = dbuser
  dbConfig.dbpassword = dbpassword
  return

_db = ""

mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
  if !err
    _db = db



exports.checkIfEmailAlreadyRegistered = (email, callback) ->
  
  if _db
    checkingIfEmailAlreadyRegistered email, _db, callback
  else
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
       callback
         "err"    : err
         "status" : false
         "data"   : ""
      else 
        _db = db
        checkingIfEmailAlreadyRegistered email, db, callback

      return
  return

checkingIfEmailAlreadyRegistered = (email, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  collection = db.collection 'useraccountdetails'
  collection.find({"email": email}).toArray (err, results) ->
    console.log results
    if results.length > 0
      result.status = true 
    else 
      result.status = false

    result.err = err
    result.data = results
    callback result
  return


exports.addNewUser = (requestingUser, callback) ->
  if _db
    addingNewUser requestingUser, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback
          "err"    : err
          "status" : false
          "data"   :
            "firstName"     : ""
            "lastName"      : ""
            "username"       : ""
            "email"          : ""
            "signinStatus"  : false
            "siginPage"     : "/signin"
            "dashboardPage" : ""
            "status"         : "Sign in"
            "toggle"         : ""
      else 
        _db = db
        addingNewUser requestingUser, db, callback

      return
  return

addingNewUser = (requestingUser, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
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
  
  collection = db.collection 'useraccountdetails'    
  collection.insert requestingUser, (err, docs) ->
    
    if err
      result.status = false
    else
      user["firstName"]     = docs[0]["firstName"]
      user["lastName"]      = docs[0]["lastName"]
      user["username"]      = docs[0]["username"]
      user["email"]         = docs[0]["email"]
      user["signinStatus"]  = true
      user["siginPage"]     = ""
      user["dashboardPage"] = "/dashboard"
      user["status"]        = docs[0]["username"]
      user["toggle"]        = "dropdown"
    
    result.err  = err
    result.data = user
    callback result

    return
  return


exports.authenticateUserCredentials  = (email, password, callback) ->
  console.log "authenticating user+++"
  if _db
    authenticatingUserCredentials email, password, _db, callback
  else
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback
          "err": err
          "status": false
          "data":
            "firstName"     : ""
            "lastName"      : ""
            "username"      : ""
            "email"         : ""
            "signinStatus"  : false
            "siginPage"     : "/signin"
            "dashboardPage" : ""
            "status"        : "Sign in"
            "toggle"        : ""
      else 
        _db = db
        authenticatingUserCredentials email, password, db, callback
      
      return  
  return


authenticatingUserCredentials = (email, password, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  
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

  collection = db.collection 'useraccountdetails'
  collection.find({"email": email}).toArray (err, results) ->
    
    if !err and results.length > 0 and results[0].password == password
      
      user["firstName"]     = results[0]["firstName"]
      user["lastName"]      = results[0]["lastName"]
      user["username"]      = results[0]["username"]
      user["email"]         = results[0]["email"]
      user["signinStatus"]  = true
      user["siginPage"]     = ""
      user["dashboardPage"] = "/dashboard"
      user["status"]        = results[0]["username"]
      user["toggle"]        = "dropdown"

      result.status = true
    else 
      result.status = false
    result.err  = err
    result.data = user
    
    callback result

        
    return
  return



#returns JSON object
exports.addSeriesToSubscribedTvShows = (subscribingTvSeries, callback) ->

  if _db
    addingSeriesToSubscribedTvShows subscribingTvSeries, _db, callback
  else
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback
          "err"    : err
          "status" : false
          "data"   : ""
      else
        _db = db
        addingSeriesToSubscribedTvShows subscribingTvSeries, db, callback 
      
      return
  return

addingSeriesToSubscribedTvShows = (subscribedTvSeries, db, callback) ->
  result =
    "err"    : ""
    "status" : ""
    "data"   : ""
 
  
  collection = db.collection 'usersubscribedtvshows'
  collection.insert subscribedTvSeries, (err, docs) ->
    if err
      result.status = false
    
    result.err    = err
    result.status = true
    result.data   = docs

    callback result
    return
  return


exports.removeSeriesFromSubscribedTvShows = (unsubscribingTvSeries, callback) ->
  if _db
    removingSeriesFromSubscribedTvShows unsubscribingTvSeries, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback 
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db 
        removingSeriesFromSubscribedTvShows unsubscribingTvSeries, db, callback
      
      return
  return   

removingSeriesFromSubscribedTvShows = (unsubscribingTvSeries, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  collection = db.collection 'usersubscribedtvshows'

  collection.remove unsubscribingTvSeries, (err, results) ->
    if err
      result.status = false
    else result.status = true
    result.err = err
    result.data = results
    console.log result
    callback result
    return
  return

exports.getSubscribedTvShows = (username, callback) ->
  if _db
    gettingSubscribedTvShows username, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback 
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db 
        gettingSubscribedTvShows username, db, callback
      
      return
  return   

gettingSubscribedTvShows = (subscriber, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  collection = db.collection 'usersubscribedtvshows'
  collection.find({"subscribersUsername": subscriber}).toArray (err, results) ->
    if err
      result.status = false
    result.err = err
    result.data = results

    console.log result
    callback result
        
  return


exports.getSubscriptionStatusForSeriesWidth = (id, username, callback) ->
  if _db
    gettingSubscriptionStatusForSeriesWidth id, username, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback 
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db 
        gettingSubscriptionStatusForSeriesWidth id, username, _db, callback
      
      return
  return 

gettingSubscriptionStatusForSeriesWidth = (id, username, db, callback) ->
  #callback "returning subscription status for series with id #{id}"
  collection = db.collection 'usersubscribedtvshows'
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  collection.find({"subscribersUsername": username, "id": id}).toArray (err, results) ->
    if err
      result.status = false
    else if results.length > 0
      result.status = true
    else result.status = false
    result.err = err
    result.data = results

    console.log result
    callback result
  return

exports.getTvShowsAiringOn = (dayOfWeek, callback) ->
  if _db
    gettingSubscribedTvShows dayOfWeek, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback 
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db 
        gettingTvShowsAiringOn dayOfWeek, db, callback
      
      return
  return   


gettingTvShowsAiringOn = (dayOfWeek, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  collection = db.collection 'usersubscribedtvshows'
  console.log "day of week", dayOfWeek
  collection.find({"airsOnDayOfWeek": dayOfWeek}).toArray (err, results) ->
    if err
      result.status = false
    result.err = err
    result.data = results

    console.log result
    callback result
        
  return





