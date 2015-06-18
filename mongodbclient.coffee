mongoClient = require('mongodb').MongoClient
format = require('util').format;
crypto = require 'crypto'
mailer = require './mailer.js'

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
            "username"      : ""
            "email"         : ""
            "signinStatus"  : false
            "siginPage"     : "/signin"
            "dashboardPage" : ""
            "status"        : "Sign in"
            "toggle"        : ""
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
    "authenticationStatus": ""

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
      user["authenticationStatus"] = results[0]["authenticationStatus"]
      user["timeZone"]      = results[0]["timeZone"]

      result.status = true
    else 
      result.err = "signin error"
      result.status = false

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

###
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
###

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



exports.deleteAccount = (username, callback) ->
  if _db
    deletingAccount username, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback 
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db 
        deletingAccount username, _db, callback
      
      return
  return   

deletingAccount = (username, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  
  userAccountCollection = db.collection 'useraccountdetails'
  userSubscriptionsCollection = db.collection 'usersubscribedtvshows'

  userAccountCollection.remove {"username": username}, (err, results) ->
    if err
      result.status = false
    else result.status = true
    result.err = err
    result.data = results
    console.log "deleting account", result
    callback result
    return

  userSubscriptionsCollection.remove {"subscribersUsername": username}, (err, results) ->
    if err
      result.status = false
    else result.status = true
    result.err = err
    result.data = results
    console.log "deleting subscriptions all", result
    #callback result
    return
  return

exports.storePasswordChangeRequest = (passwordResetObject, callback) ->
  if _db
    storingPasswordChangeRequest passwordResetObject, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback 
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db 
        storingPasswordChangeRequest passwordResetObject, _db, callback
      
      return
  return   

storingPasswordChangeRequest = (passwordResetObject, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  
  collection = db.collection 'passwordchangerequests'    
  collection.insert passwordResetObject, (err, docs) ->
    
    if err
      result.status = false
    
    result.err  = err
    result.data = docs
    callback result

    return
  
  return

exports.updatePassword = (token, newPassword, callback) ->
  if _db
    updatingPassword token, newPassword, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback 
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db 
        updatingPassword token, newPassword, _db, callback
      
      return
  return   

updatingPassword = (token, newPassword, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  
  passwordChangeRequestsCollection = db.collection 'passwordchangerequests'

  shasum = crypto.createHash 'sha1'
  shasum.update token
  tokenhash = shasum.digest 'hex'



  passwordChangeRequestsCollection.find({"tokenHash": tokenhash}).toArray (err, results) ->
    console.log results
    
    if results.length == 1
      result.status = true 
      email = results[0].email
      collection = db.collection 'useraccountdetails' 
      
      collection.update {"email": email},{ $set: { "password" : newPassword } }, (err, docs) ->
        
        if err
          result.status = false
        else 
          result.status = true
        
        result.err  = err
        result.data = docs
        callback result

        return   
    else 
      result.status = false

      result.err = err
      result.data = results
      callback result
    return
  return


exports.addUnauthenticatedUser = (unauthenticatedUserObject, callback) ->
  if _db
    addingUnauthenticatedUser unauthenticatedUserObject, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback 
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db 
        addingUnauthenticatedUser unauthenticatedUserObject, _db, callback
      
      return
  return   

addingUnauthenticatedUser = (unauthenticatedUserObject, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  
  token = unauthenticatedUserObject.token
  unauthenticatedUserObject.token = generateHash unauthenticatedUserObject.token
  
  collection = db.collection 'unauthenticatedaccounts'    
  collection.insert unauthenticatedUserObject, (err, docs) ->
    
    if err
      result.status = false
      result.err  = err
      result.data = docs
      callback result
    else
      body = "<div><p>You have successfully set up your TV Series account and you can now access it by clicking on the following link:</p></div><div><p><a href='http://webapp.tvseries.dev/authenticateAccount?token=#{token}'> http://webapp.tvseries.dev/authenticateAccount?token=#{token} </a></p></div>"
      mailOptions =
        from    : 'TV Series <tvserieswebapp@gmail.com>'
        to      : unauthenticatedUserObject.email
        subject : 'Authenticate your TV Series Account'
        text    : '' 
        html    : body

      mailer.sendMail mailOptions, callback
    
    

    return
  
  return

generateHash = (string) ->
  shasum = crypto.createHash 'sha1'
  shasum.update string
  hashValue = shasum.digest 'hex'
  return hashValue

exports.authenticateAccount = (token, callback) ->
  if _db
    authenticatingAccount token, _db, callback
  else 
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback 
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db 
        authenticatingAccount token, _db, callback
      
      return
  return

authenticatingAccount = (token, db, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  
  unauthenticatedAccountsCollection = db.collection 'unauthenticatedaccounts'

  shasum = crypto.createHash 'sha1'
  shasum.update token
  token = shasum.digest 'hex'


  console.log "finding token"
  unauthenticatedAccountsCollection.find({"token": token}).toArray (err, results) ->
    console.log results
    
    if results.length == 1
      result.status = true 
      email = results[0].email
      collection = db.collection 'useraccountdetails' 
      console.log "updating account"
      collection.update {"email": email},{ $set: { "authenticationStatus" : true } }, (err, docs) ->
        
        if err
          result.status = false
        else 
          result.status = true
        
        result.err  = err
        result.data = docs
        callback result

        return   
    else 
      result.status = false

      result.err = err
      result.data = results
      callback result
    return
  return


exports.deleteExpiredPasswordResetTokens = (options, callback) ->
  createMongodbConnectionAndPerform (options, db, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""
    
    collection = db.collection 'passwordchangerequests'

    collection.find({}).toArray (err, results) ->
      console.log results
      if results.length > 0
        for request in results
          if new Date(request.expires) < new Date()
            console.log "original date", new Date(request.expires), "curr date", new Date()
            collection.remove request, (err, results) ->
              console.log result, "removed"
              return

      return
    #callback "deleting expired password reset tokens"
    return
  ,
  options,callback
  return

exports.deleteExpiredAccountAuthenticationTokens = (options, callback) ->
  createMongodbConnectionAndPerform (options, db, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""
    
    collection = db.collection 'unauthenticatedaccounts'

    collection.find({}).toArray (err, results) ->
      console.log results
      if results.length > 0
        for request in results
          if new Date(request.expires) < new Date()
            console.log "account token deleted original date", new Date(request.expires), "curr date", new Date()
            collection.remove request, (err, results) ->
              console.log result, "removed"
              return

      return
    #callback "deleting expired password reset tokens"
    return
  ,
  options,callback
  return



exports.addNewJob = (options, callback) ->
  createMongodbConnectionAndPerform (options, db, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""
    
    collection = db.collection 'jobs'
    collection.insert options.object, (err, docs) ->
    
      if err
        result.status = false
      else
        result.status = true
      
      result.err  = err
      result.data = docs
      callback result

    return
    
    #callback "deleting expired password reset tokens"
    return
  ,
  options,callback
  return




exports.getTvShowsAiringOn = (options, callback) ->
  createMongodbConnectionAndPerform (options, db, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""
    
    collection = db.collection 'usersubscribedtvshows'
    console.log "day of week", options.object
    collection.find(options.object).toArray (err, results) ->
      if err
        result.status = false
      else 
        result.status = true
      
      result.err = err
      result.data = results
      console.log result
      callback result
      return
    return
  ,
  options,callback
  return


exports.getMailSubscriptionJobs = (options, callback) ->
  createMongodbConnectionAndPerform (options, db, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""
    
    collection = db.collection 'jobs'
    
    collection.find(options.object).toArray (err, results) ->
      if err
        result.status = false
      else 
        result.status = true
      
      result.err = err
      result.data = results
      console.log result
      callback result
      return
    return
  ,
  options,callback
  return

exports.checkIfJobsCreated = (options, callback) ->
  createMongodbConnectionAndPerform (options, db, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""
    
    collection = db.collection 'jobscreatedstatus'
    
    collection.find(options.object).toArray (err, results) ->
      if err
        result.status = false
      else 
        result.status = true
      
      if results.length == 0
        result.status = false
        
      result.err = err
      result.data = results
      console.log result
      callback result
      return
    return
  ,
  options,callback
  return


exports.addEntryToJobsCreatedStatusCollection = (options, callback) ->
  createMongodbConnectionAndPerform (options, db, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""
    
    collection = db.collection 'jobscreatedstatus'
    collection.insert options.object, (err, docs) ->
    
      if err
        result.status = false
      else
        result.status = true
      
      result.err  = err
      result.data = docs
      callback result

      return
    
    return
  ,
  options,callback
  return










###

exports.updateDocumentInCollection = (options, callback) ->

  createMongodbConnectionAndPerform (options, db, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""

    collection = db.collection options.collection

    collection.update options.object.searchParameter, { $set: options.object.updatedValue }, (err, docs) -> 
      if err
        result.status = false
      else 
        result.status = true
      
      result.err  = err
      result.data = docs
      callback result
      return
  ,
  options, callback   

  return
###

createMongodbConnectionAndPerform = (job, options, callback) ->
  if _db
    job options, _db, callback
  else
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db
        job options, _db, callback

      return
  return


###
  connects to mongodb and perform the required operation passed as job and on completion of the job calls the callback
###
connectToMongodbAndPerform = (job, options, callback) ->
  if _db
    options.collection = _db.collection options.collection
    job options, callback
  else
    mongoClient.connect "mongodb://#{dbConfig.dbuser}:#{dbConfig.dbpassword}@ds029640.mongolab.com:29640/tvserieswebappdatabase", (err, db) ->
      if err
        callback
          "err"    : err
          "status" : false
          "data"   : ""
      else 
        _db = db
        options.collection = _db.collection options.collection
        job options, callback

      return
  return




###
search for a document in collection
###
searchDocumentInCollection = (options, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  

  console.log "search ", options.object
  collection = options.collection

  
  
  collection.find(options.object).toArray (err, results) ->
    if err
      result.status = false
    else 
      result.status = true
    
    result.err = err
    result.data = results
    console.log result
    callback result
    return
  return
exports.searchDocumentInCollection = searchDocumentInCollection




###
delete document from a  collection
###
deleteDocumentFromCollection = (options, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""
  
  collection = options.collection
  
  collection.remove options.object, (err, results) ->
    if err
      result.status = false
    else result.status = true
    result.err = err
    result.data = results
    console.log result
    callback result
    return
  return
exports.deleteDocumentFromCollection = deleteDocumentFromCollection




### 
  checks for availability of username
###
exports.checkUsernameAvailability = (options, callback) ->
  options.collection = 'useraccountdetails'
  connectToMongodbAndPerform searchDocumentInCollection, options, callback
  return





###
  removes tv shows from subscribed list for a given user
###

exports.removeSeriesFromSubscribedTvShows = (options, callback) ->
  options.collection = 'usersubscribedtvshows'
  connectToMongodbAndPerform removingSeriesFromSubscribedTvShows, options, callback
  return

removingSeriesFromSubscribedTvShows = (options, callback) ->
  result = 
    "err"    : ""
    "status" : ""
    "data"   : ""

  collection = options.collection

  (() ->
    tvShowsToBeUnsubscribed = options.object
    counter = 0
    tvShowsUnsubscribedCount = 0
    limit = tvShowsToBeUnsubscribed.length
    
    for tvShow in tvShowsToBeUnsubscribed
      console.log "series", tvShow
      


      collection.remove {subscribersUsername:"#{tvShow.subscribersUsername}", id: "#{tvShow.id}"}, (err, docs) -> 
        counter++
        if err
          result.status = false
        else 
          result.status = true
        
        result.err  = err
        result.data = docs

        if docs.data == 1
          tvShowsUnsubscribedCount++

        if counter == limit
          if counter == tvShowsUnsubscribedCount
            result.err = 
              "msg" : "some tv shows were not unsubscribed"

          callback result
        return
    return
  )()
  return

###
  add document to collection
###
addDocumentToCollection = (options, callback) ->
  connectToMongodbAndPerform (options, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""
    
    collection = options.collection
    collection.insert options.object, (err, docs) ->

      if err
        result.status = false
      else
        result.status = true
      
      result.err  = err
      result.data = docs
      callback result
      return
    return
  , options, callback
  return
exports.addDocumentToCollection = addDocumentToCollection


exports.updateDocumentInCollection = (options, callback) ->
  
  connectToMongodbAndPerform (options, callback) ->
    result = 
      "err"    : ""
      "status" : ""
      "data"   : ""

    collection = options.collection

    collection.update options.object.searchParameter, { $set: options.object.updatedValue }, (err, docs) -> 
      if err
        result.status = false
      else 
        result.status = true
      
      result.err  = err
      result.data = docs
      callback result
      return
  ,
  options, callback   
  return



































