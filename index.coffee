tvdbWebService = require 'tvdbwebservice'
express = require 'express'
app = express()

fs = require "fs"
path = require 'path'
http = require 'http'
handlebars = require "handlebars"
crypto = require 'crypto'
mailer = require('./mailer.js')

jobs = require './jobs.js'





#app config
app.set 'port', (process.env.PORT)
app.set 'tvdbApiKey', (process.env.TVDB_API_KEY)
app.set 'emailusername', (process.env.emailusername)
app.set 'emailpassword', (process.env.emailpassword)


#tvdbwebservice config
tvdbWebService.setTvdbApiKey app.get 'tvdbApiKey'

#mailer config
mailer.setEmailAccount
  "username": app.get 'emailusername'
  "password": app.get 'emailpassword'


# mongo db config
mongodbclient = require('./mongodbclient.js')
mongodbclient.setDbConfig process.env["DB_USER"], process.env["DB_PASSWORD"]
cookieParser = require('cookie-parser')
app.use(cookieParser());


#mongo connect session config
session = require('express-session');
MongoStore = require('connect-mongo')(session);


#handlebars helpers
handlebars.registerHelper 'raw-helper', (options) ->
  options.fn()



app.use session 
  "secret" : '67gvgchgch987jbcfgxdfmhye435jvgxzdzf'
  "store"  : new MongoStore
    "url" : "mongodb://#{process.env["DB_USER"]}:#{process.env["DB_PASSWORD"]}@ds029640.mongolab.com:29640/tvserieswebappdatabase"
    "ttl" : 1*24*60*60*1000
  "cookie" : 
    "maxAge" : 1*24*60*60*1000
  "resave": false
  "saveUninitialized": true


bodyParser = require('body-parser');
multer = require('multer'); 

app.use(bodyParser.json()); 
app.use(bodyParser.urlencoded({ extended: true })); 
app.use(multer()); 




#caching up the templates

indexHTML          = fs.readFileSync "public/index.html", "utf8"
seriesHTML         = fs.readFileSync "public/series.html", "utf8"
signupHTML         = fs.readFileSync "public/account/signup.html", "utf8"
signinHTML         = fs.readFileSync "public/account/signin.html", "utf8"
dashboardHTML      = fs.readFileSync "public/account/dashboard.html", "utf8"
forgotPasswordHTML = fs.readFileSync "public/account/forgot-password.html", "utf8"
resetPasswordHTML  = fs.readFileSync "public/account/reset-password.html", "utf8"
reportsHTML        = fs.readFileSync "public/reports.html", "utf8"


seriesTemplate         = handlebars.compile seriesHTML
signupTemplate         = handlebars.compile signupHTML
signinTemplate         = handlebars.compile signinHTML
dashboardTemplate      = handlebars.compile dashboardHTML
forgotPasswordTemplate = handlebars.compile forgotPasswordHTML
resetPasswordTemplate  = handlebars.compile resetPasswordHTML
reportsTemplate        = handlebars.compile reportsHTML


###================================================================================================
Routs
================================================================================================###



app.use (req, res, next) -> 
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"
  next()
  return




#routs to access TVDB


app.get '/series/seriesName/:name', (req, res) ->
  tvdbWebService.getSeriesByName req.params.name, (data) ->
  	res.end data
  	return
  return


# responds to requests for series with given id for series data + actors  + banners
app.get '/series/seriesId/:id/seriesPlusActorsPlusBanners',  (req, res) ->
  tvdbWebService.getSeriesPlusActorsPlusBannersById req.params.id, (data) ->
  	res.end data
  	return
  return
# responds to requests for series with given id for seriesData only
app.get '/series/seriesId/:id/seriesOnly', (req, res) ->
  tvdbWebService.getSeriesOnlyById req.params.id, (data) ->
  	res.end data
  	return
  return


# responds to requests for actors of series with given id
app.get '/series/seriesId/:id/actors',  (req, res) ->
  tvdbWebService.getActorsForSeriesWithId req.params.id, (data) ->
  	res.end data
  	return
  return

# responds to requests for banners of series with given id
app.get '/series/seriesId/:id/banners/', (req, res) ->
  tvdbWebService.getBannersForSeriesWithId req.params.id, (data) ->
  	res.end data
  	return
  return

app.get '/series?id=:id/episode?airDate=:airDate', (req, res) ->
  tvdbwebservice.getEpisodeAiredOnDateForSeriesWithId req.params.airDate, req.params.id, (data) ->
    res.end data
    return
  return





#routs to access the app


#accessing the homepage
app.get '/', (req, res)  ->  
  console.log "requesting series homepage"
  
  if !indexTemplate
    indexHTML = fs.readFileSync "public/index.html", "utf8"
    indexTemplate = handlebars.compile(indexHTML)
  
  signinObject = 
    "firstName"     : ""
    "lastName"      : ""
    "username"      : ""
    "email"         : ""
    "signinStatus"  : false
    "signinPage"    : "/signin?redirect=/"
    "dashboardPage" : ""
    "status"        : "Sign in"
    "toggle"        : ""
    "signout"       : ""




  if req.session.username
    signinObject = 
      "firstName"     : req.session["firstName"]
      "lastName"      : req.session["lastName"]
      "username"      : req.session.username
      "email"         : req.session.email
      "signinStatus"  : true
      "signinPage"     : ""
      "dashboardPage" : "/dashboard"
      "status"        : req.session.username
      "toggle"        : "dropdown"
      "signout"       : "/signout?redirect=/"

  
  result = indexTemplate signinObject

  console.log "account:", signinObject

  res.writeHead 200, {"Context-Type": "text/html"}
  res.write result
  res.end()

  return


app.get '/search', (req, res) ->
  res.redirect '/'
  return

#request for signup
app.get '/signup', (req, res) ->
  console.log "signup"

  #redirect = req.query.redirect

  res.writeHead 200, {"Context-Type": "text/html"}
  signupObject = 
    "error"    : null
    "redirect" : null

  if req.session.errorDataOnSignup
    signupObject.error = req.session.errorDataOnSignup

  if !signupTemplate
    signupHTML = fs.readFileSync "public/signup.html", "utf8"
    signupTemplate = handlebars.compile signupHTML

  req.session.errorDataOnSignup = null
  
  result = signupTemplate signupObject
  res.write result


  res.end()
  return


#to handle posts from signup form
app.post '/signup', (req, res)  ->

  req.session["firstName"] = ""
  req.session["lastName"] = ""
  req.session.username = ""
  req.session.email    = ""
  req.session["signinStatus"] = false

  req.session.errorDataOnSignup =
    "firstName" : req.body["firstName"]
    "lastName"  : req.body["lastName"]
    "username"  : req.body["username"]
    "email"     : req.body["email"]
    "timeZone"  : req.body["timeZone"] 

  mongodbclient.checkIfEmailAlreadyRegistered req.body.email, (mailStausResult) ->
    console.log "found status", mailStausResult
    if !mailStausResult.status
      shasum = crypto.createHash 'sha1';
      shasum.update req.body["password"]
      password = shasum.digest 'hex'
      req.session.errorDataOnSignup = null
      mongodbclient.addNewUser
        "firstName"            : req.body["firstName"]
        "lastName"             : req.body["lastName"]
        "username"             : req.body["username"]
        "email"                : req.body["email"]
        "password"             : password
        "timeZone"             : req.body["timeZone"] 
        "authenticationStatus" : false
      ,
      (result) ->
        expires = new Date()
        expires.setHours expires.getHours() + 24
        
        unauthenticatedUser = 
          "token"   : ""
          "expires" : expires
          "email"   : req.body.email

        generateAccountAuthenticationToken unauthenticatedUser, (result) ->
          console.log "account authentication token created", result
          return

        res.redirect '/signin'
        return
    else
      req.session.emailAlreadyRegisteredWhileSignup = true;
      res.redirect '/signup' 
    return
  return

app.post '/checkUsernameAvailability', (req, res) ->
  console.log "checking usernameavailibilty",req.body
  
  mongodbclient.checkUsernameAvailability 
    "object" : 
      "username" : req.body.username
  , 
  (result) ->
    console.log "result", result
    if !result.err
      if result.data.length == 0
        result.data = 1
        result.status = true
      else 
        result.data = 0
        result.status = false
    res.end JSON.stringify result, null, 4
    return
  
  return



#handle requests for series page
app.get '/series', (req, res)  ->
  console.log 'requesting series', req.query
  if !req.query.name or !req.query.id
    res.redirect '/seriesNotFound'

  if !seriesHTML
    indexHTML = fs.readFileSync "public/series.html", "utf8"
  
  seriesPageData = 
    "firstName"     : ""
    "lastName"      : ""
    "username"      : ""
    "email"         : ""
    "signinStatus"  : false
    "signinPage"    : "/signin?redirect=/series&&name=#{req.query.name}&id=#{req.query.id}&bannerUrl=#{req.query.bannerUrl}&altBannerUrl=#{req.query.altBannerUrl}"
    "dashboardPage" : ""
    "status"        : "Sign in"
    "toggle"        : ""
    "name"          : req.query.name
    "id"            : req.query.id
    "bannerUrl"     : req.query.bannerUrl
    "altBannerUrl"  : req.query.altBannerUrl
    "signout"       : ""

  if req.session.username
    seriesPageData = 
      "firstName"     : req.session["firstName"]
      "lastName"      : req.session["lastName"]
      "username"      : req.session.username
      "email"         : req.session.email
      "signinStatus"  : true
      "signinPage"    : ""
      "dashboardPage" : "/dashboard"
      "status"        : req.session.username
      "toggle"        : "dropdown"
      "name"          : req.query.name
      "id"            : req.query.id
      "bannerUrl"     : req.query.bannerUrl
      "altBannerUrl"  : req.query.altBannerUrl
      "signout"       : "/signout?redirect=/series&&name=#{req.query.name}&id=#{req.query.id}&bannerUrl=#{req.query.bannerUrl}&altBannerUrl=#{req.query.altBannerUrl}"

  template = handlebars.compile seriesHTML
  result = template seriesPageData

  res.writeHead 200, {"Context-Type": "text/html"}
  res.write result 
  res.end()

  return


app.get '/deleteAccount', (req, res) ->
  if req.session.username
    username = req.session.username
    req.session.destroy (err) ->
      return

    mongodbclient.deleteAccount username, (result) ->
      if !result.err
        res.redirect '/'
      return
  else


app.get '/authenticateAccount', (req, res) ->
  token = req.query.token
  
  mongodbclient.authenticateAccount token, (result) ->
    console.log "account authenticatec status", result
    
    if !result.err && result.data == 1
      reportsPageData = 
        "title"        : "Authenticate account"
        "mainMessage"  : "Your TV Series account was successfully authenticated"
        "otherMessage" : "Redirecticting to signin in 5 seconds ..."
    else
      reportsPageData = 
        "title"       : "Authenticate account"
        "mainMessage" : "Unable to process the request"
    
    if !reportsHTML
      reportsHTML = fs.readFileSync "public/reports.html", "utf8"
    
    template = handlebars.compile reportsHTML
    result = template reportsPageData

    res.writeHead 200, {"Context-Type": "text/html"}
    res.write result 
    res.end()
    return

app.get '/reports', (req, res) ->
  reportsPageData = 
    "mainMessage"  : "Your TV Series account was successfully authenticated"
    "otherMessage" : "Redirecticting to signin in 5 seconds ..."

  if !reportsHTML
    reportsHTML = fs.readFileSync "public/reports.html", "utf8"
  
  template = handlebars.compile reportsHTML
  result = template reportsPageData

  #res.writeHead 200, {"Context-Type": "text/html"}
  #res.writeHead 301, {Location: '/'}
  #res.writeHead 302, {"Refresh", "10; URL='/'"}
  
  
  console.log "res headers", res


  res.write result 
  res.end()

  return   

app.get '/mailAccountAuthenticationLink', (req, res) ->
  if req.session.email
    expires = new Date()
    expires.setMinutes expires.getMinutes() + 30
    
    unauthenticatedUser = 
      "token"   : ""
      "expires" : expires
      "email"   : req.session.email

    generateAccountAuthenticationToken unauthenticatedUser, (result) ->
      console.log "account authentication token created", result
      res.redirect '/signin'
      return

  return 



app.get '/forgotPassword', (req, res)  ->
  console.log 'requesting forgot password page', req.query
  if !forgotPasswordHTML
    forgotPasswordHTML = fs.readFileSync "public/account/forgot-password.html", "utf8"
  
  forgotPasswordPageData = 
    "message"     : ""
    "email"       : ""

  


  template = handlebars.compile forgotPasswordHTML
  result = template forgotPasswordPageData

  res.writeHead 200, {"Context-Type": "text/html"}
  res.write result 
  res.end()

  return


app.post '/forgotPassword', (req, res)  ->
  console.log 'requesting forgot password page', req.bod
  if !forgotPasswordHTML
    forgotPasswordHTML = fs.readFileSync "public/account/forgot-password.html", "utf8"
  
  forgotPasswordPageData = 
    "message"     : "A password reset link has been sent to your mail"
    "email"       : req.body.email

  mailer.mailPasswordResetLinkTo req.body.email 

  template = handlebars.compile forgotPasswordHTML
  result = template forgotPasswordPageData

  res.writeHead 200, {"Context-Type": "text/html"}
  res.write result 
  res.end()

  return


app.get '/resetPassword', (req, res)  ->
  console.log 'requesting reset password page'
  if !resetPasswordHTML
    resetPasswordHTML = fs.readFileSync "public/account/reset-password.html", "utf8"
  
  resetPasswordPageData = 
    "message"            : ""
    "passwordResetToken" : req.query.token


  template = handlebars.compile resetPasswordHTML
  result = template resetPasswordPageData

  res.writeHead 200, {"Context-Type": "text/html"}
  res.write result 
  res.end()

  return


app.post '/resetPassword', (req, res)  ->
  newPassword = generateHash req.body.password
  mongodbclient.updatePassword req.body.passwordResetToken, newPassword, (result) ->
    console.log "password updated successfully"
    res.redirect '/signin'
    return

  return






app.get '/signin-status', (req, res) ->
  if req.session.username
    req.session["signin-status"] = true
  else req.session["signin-status"] = false
  
  res.end JSON.stringify
    "firstName"    : req.session["firstName"]
    "email"        : req.session["email"]
    "username"     : req.session["username"]
    "signinStatus" : req.session["signinStatus"]
  return

app.get '/signout', (req, res) ->
  req.session.destroy (err) ->
    redirectUrl = ""
    if req.query.redirect == "/series"
      redirectUrl = "/series?name=#{req.query.name}&id=#{req.query.id}&bannerUrl=#{req.query.bannerUrl}&altBannerUrl=#{req.query.altBannerUrl}"
    else redirectUrl = req.query.redirect
    
    res.redirect redirectUrl
    return
  return




app.get '/signin', (req, res) ->
  if req.session.signinStatus
    res.redirect '/'

  console.log "redirect", req.query.redirect

  if req.query.redirect
    if req.query.id
      redirect = "#{req.query.redirect}?name=#{req.query.name}&id=#{req.query.id}&bannerUrl=#{req.query.bannerUrl}&altBannerUrl=#{req.query.altBannerUrl}"
    else
      redirect = "#{req.query.redirect}"
  else 
      redirect = "/"

  res.writeHead 200, {"Context-Type": "text/html"}
  signinObject = 
    "email"        : ""
    "errorMessage" : null
    "redirect"     : redirect

  if !signinTemplate
    signinHTML = fs.readFileSync "public/signin.html", "utf8"
    signinTemplate = handlebars.compile signinHTML
  
  result = signinTemplate signinObject
  res.write result
  res.end()
  return





app.post '/signin', (req, res) ->
  shasum = crypto.createHash 'sha1'
  shasum.update req.body["password"]
  password = shasum.digest 'hex'

  redirect = req.body.redirect
  mongodbclient.authenticateUserCredentials req.body.email, password, (result) ->

    console.log result
    if !result.err && result.data.authenticationStatus
      req.session.username                = result.data.username
      req.session["firstName"]            = result.data.firstName
      req.session["lastName"]             = result.data.lastName
      req.session["email"]                = result.data.email
      req.session["username"]             = result.data.username
      req.session["authenticationStatus"] = result.data.authenticationStatus
      req.session["signinStatus"]         = result.data["signinStatus"]
      req.session["timeZone"]             = result.data["timeZone"]
      res.redirect redirect
    else 
      res.writeHead 200, {"Context-Type": "text/html"}
      if !signinTemplate
        signinHTML = fs.readFileSync "public/account/signin.html", "utf8"
        signinTemplate = handlebars.compile signinHTML

      signinObject = 
        "errorMessage"         : "Either the username or password you entered is wrong"
        "authenticationStatus" : "Your TV Series Account is not authenticated"
        "unauthenticated"      : !result.data.authenticationStatus
        "redirect"             : redirect

      if !result.err
        signinObject.errorMessage = ""
      else
        signinObject.authenticationStatus = "" 

      console.log "signinTemplate", signinObject
      
      renderedPage = signinTemplate signinObject
      res.write renderedPage
      res.end()
    return
  return

app.get '/dashboard', (req, res) ->
  console.log "requesting dashboard"
  if !req.session["signinStatus"]
    res.redirect '/signin'
  else 
    signinObject = 
      "firstName"     : req.session["firstName"]
      "lastName"      : req.session["lastName"]
      "username"      : req.session.username
      "email"         : req.session.email
      "signinStatus"  : true
      "signinPage"     : ""
      "dashboardPage" : "/dashboard"
      "status"        : req.session.username
      "toggle"        : "dropdown"
      "signout"       : "/signout?redirect=/"
    
    res.writeHead 200, {"Context-Type": "text/html"}
    
    if !dashboardTemplate
      dashboardHTML = fs.readFileSync "public/account/dashboard.html", "utf8"
      dashboardTemplate = handlebars.compile dashboardHTML
    result = dashboardTemplate signinObject
    res.write result
    res.end()



# results the subscribed TV Shows
app.get '/subscriptions', (req, res) ->
  if !req.session["signinStatus"]
    res.redirect '/signin'
  else 
    mongodbclient.getSubscribedTvShows req.session.username, (result) ->
      console.log "result is ",result
      console.log "sending server data to client"
      res.end JSON.stringify result, null, 4
      return
  return


app.get '/subscribe', (req, res) ->  
  if !req.session["signinStatus"]
    res.end JSON.stringify
      "err": 
        "code": "401"
        "message": "Not Signedin"
      "status": false
      "data": null
  else  
    subscribingTvSeries = 
      "subscribersUsername"  : req.session.username
      "subscribersFirstName" : req.session.firstName
      "subscribersLastName"  : req.session.lastName
      "subscribersEmail"     : req.session.email
      "id"                   : req.query.id
      "name"                 : req.query.name 
      "artworkUrl"           : req.query.artworkUrl
      "airsOnDayOfWeek"      : req.query.airsOnDayOfWeek
      "subscribersTimeZone"  : req.session.timeZone
    mongodbclient.addSeriesToSubscribedTvShows subscribingTvSeries, (result) ->
      res.end JSON.stringify result, null, 4
  return

app.post '/unsubscribe', (req, res) ->
  if !req.session["signinStatus"]
    res.end JSON.stringify
      "err": 
        "code": "401"
        "message": "Not Signedin"
      "status": false
      "data": null
  else
    tvShowsToBeUnsubscribed = req.body.tvShowsToBeUnsubscribed
    for tvShow in tvShowsToBeUnsubscribed
      tvShow["subscribersUsername"] = req.session.username

    console.log "tv series object to be unsubscribed -\n", tvShowsToBeUnsubscribed
    mongodbclient.removeSeriesFromSubscribedTvShows {"object":tvShowsToBeUnsubscribed}, (result) ->
      console.log result
      res.end JSON.stringify result, null, 4
  return


app.get '/subscriptions/getSeries',  (req, res) ->
  if req.session.signinStatus
    console.log "checking subscription status for series with id", req.query.id
    mongodbclient.getSubscriptionStatusForSeriesWidth req.query.id, req.session.username, (result) ->
      res.end JSON.stringify result, null, 4
  else
    res.end JSON.stringify 
      "err"    : null
      "status" : false
      "data"   : ""
  return


# server = app.listen app.get('port'), ->
console.log "Attempting to start server at #{app.get('port')}"
server = http.createServer(app).listen app.get('port'), ->
  ##
  address = server.address()
  console.log "Node app is running at ", address
  if process.platform is 'darwin'
    powHost = "webapp.tvseries"
    powFile = path.resolve process.env['HOME'], ".pow/#{powHost}"
    fs.writeFile powFile, address.port, (err) =>
      return console.error err if err
      console.log "Hosted on: #{powHost}.dev"
      unhost = ->
        try
          fs.unlinkSync powFile
          console.log "Unhosted from: #{powHost}.dev"
        catch e
          return console.error err if err
        return
      process.on 'SIGINT', -> unhost(); process.exit(); return
      process.on 'exit', (code) -> unhost(); return
  ##
  return



###
  to be used if none of route matches
###
app.use express.static __dirname + '/public'



###
  last route the 404
###
app.get '/*', (req, res) ->
  reportsPageData = 
    "title"        : "Page not found"
    "mainMessage"  : "The page you’re looking for can’t be found"
    "otherMessage" : "Try one of the links below"

  if !reportsHTML
    reportsHTML = fs.readFileSync "public/reports.html", "utf8"
  
  template = handlebars.compile reportsHTML
  result = template reportsPageData

  res.status 404
  res.write result 
  res.end()

  return  

###
(() ->
  
  days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  currentDay = days[(new Date()).getDay()]
  subscribers = {}
  allUsers = []
  temp = []
  mongodbclient.getTvShowsAiringOn currentDay, (result) ->
    #console.log "TV Shows Airing on #{currentDay} -\n", result

    

    for tvShow in result.data

      if !subscribers[tvShow.subscribersUsername]
        subscribers[tvShow.subscribersUsername] = {}
        subscribers[tvShow.subscribersUsername].tvShows = []
        subscribers[tvShow.subscribersUsername].email = tvShow.subscribersEmail
        subscribers[tvShow.subscribersUsername].username = tvShow.subscribersUsername
        subscribers[tvShow.subscribersUsername].name = tvShow.subscribersFirstName + " " + tvShow.subscribersLastName

        allUsers.push tvShow.subscribersUsername
      subscribers[tvShow.subscribersUsername].tvShows.push 
        "name"       : tvShow.name
        "id"         : tvShow.id
        "artworkUrl" : tvShow.artworkUrl

    #console.log "subscribers today -\n", JSON.stringify subscribers, null, 4

    for user in allUsers
      temp.push
        "email"    : subscribers[user].email
        "name"     : subscribers[user].name
        "username" : subscribers[user].username
        "tvShows"  : subscribers[user].tvShows
    
    console.log JSON.stringify temp, null, 4
    mailer.mailSubscriptions(temp)
    return
  return
)()
###




generateAccountAuthenticationToken = (unauthenticatedUser, callback) ->
  crypto.randomBytes 32, (ex, buf) ->
    token = buf.toString 'hex'

    unauthenticatedUser.token = token
    mongodbclient.addUnauthenticatedUser unauthenticatedUser, callback
    return
  return

generateHash = (string) ->
  shasum = crypto.createHash 'sha1'
  shasum.update string
  hashValue = shasum.digest 'hex'
  return hashValue





#jobs.performJobs()

















