tvdbWebService = require 'tvdbwebservice'
express = require 'express'
app = express()

fs = require "fs"
path = require 'path'
http = require 'http'
handlebars = require "handlebars"


#app config
app.set 'port', (process.env.PORT)
app.set 'tvdbApiKey', (process.env.TVDB_API_KEY)


#tvdbwebservice config
tvdbWebService.setTvdbApiKey app.get 'tvdbApiKey'


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

indexHTML     = fs.readFileSync "public/index.html", "utf8"
seriesHTML    = fs.readFileSync "public/series.html", "utf8"
signupHTML    = fs.readFileSync "public/account/signup.html", "utf8"
signinHTML    = fs.readFileSync "public/account/signin.html", "utf8"
dashboardHTML = fs.readFileSync "public/account/dashboard.html", "utf8"

indexTemplate     = handlebars.compile indexHTML
seriesTemplate    = handlebars.compile seriesHTML
signupTemplate    = handlebars.compile signupHTML
signinTemplate    = handlebars.compile signinHTML
dashboardTemplate = handlebars.compile dashboardHTML

redirect = ""


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




app.get '/series', (req, res)  ->
  console.log 'requesting series', req.query
  if !seriesHTML
    indexHTML = fs.readFileSync "public/series.html", "utf8"
  
  seriesPageData = 
    "firstName"     : ""
    "lastName"      : ""
    "username"      : ""
    "email"         : ""
    "signinStatus"  : false
    "signinPage"    : "/signin?redirect=/series"
    "dashboardPage" : ""
    "status"        : "Sign in"
    "toggle"        : ""
    "name"          : req.query.name
    "id"            : req.query.id
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
      "signout"       : "/signout?redirect=/series"

  template = handlebars.compile seriesHTML
  result = template seriesPageData

  res.writeHead 200, {"Context-Type": "text/html"}
  res.write result 
  res.end()

  return



app.post '/signup', (req, res)  ->

  req.session["firstName"] = ""
  req.session["lastName"] = ""
  req.session.username = ""
  req.session.email    = ""
  req.session["signinStatus"] = false

  mongodbclient.checkIfEmailAlreadyRegistered req.body.email, (mailStausResult) ->
    console.log "found status", mailStausResult
    if !mailStausResult.status
      mongodbclient.addNewUser
        "firstName" : req.body["firstName"]
        "lastName"  : req.body["lastName"]
        "username"  : req.body["username"]
        "email"     : req.body["email"]
        "password"  : req.body["password"]   
      ,
      (result) ->
        req.session["firstName"]    = result.data["firstName"]
        req.session["lastName"]     = result.data["lastName"]
        req.session.username        = result.data.username
        req.session.email           = result.data.email
        req.session["signinStatus"] = true
        res.redirect '/'
        return
    else
      res.redirect '/account/signup.html' 
    return
  return

#app.get '/signup', (req, res) ->


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
    res.redirect req.query.redirect
    return
  return




app.get '/signin', (req, res) ->
  console.log "redirect", req.query.redirect
  redirect = req.query.redirect
  res.writeHead 200, {"Context-Type": "text/html"}
  signinObject = 
    "email"        : ""
    "errorMessage" : ""

  if !signinTemplate
    signinHTML = fs.readFileSync "public/signin.html", "utf8"
    signinTemplate = handlebars.compile signinHTML
  
  result = signinTemplate signinObject
  res.write result


  res.end()
  
  return





app.post '/signin', (req, res) ->
  mongodbclient.authenticateUserCredentials req.body.email, req.body.password, (result) ->

    req.session.username     = result.data.username
    req.session["firstName"] = result.data.firstName
    req.session["lastName"]  = result.data.lastName
    req.session["email"]     = result.data.email
    req.session["username"]  = result.data.username
    

    req.session["signinStatus"] = result.data["signinStatus"]
    
    if req.session["signinStatus"]
      res.redirect redirect
    else 
      res.writeHead 200, {"Context-Type": "text/html"}
      if !signinTemplate
        signinHTML = fs.readFileSync "public/account/signin.html", "utf8"
        signinTemplate = handlebars.compile signinHTML

      result.data["errorMessage"] = "Either the username or password you entered is wrong"
      result = signinTemplate result.data
      res.write result
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
    res.redirect '/signin?redirect=/series'
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
    mongodbclient.addSeriesToSubscribedTvShows subscribingTvSeries, (result) ->
      res.end JSON.stringify result, null, 4
  return

app.get '/unsubscribe', (req, res) ->
  if !req.session["signinStatus"]
    res.redirect '/signin?redirect=/series'
  else
    unsubscribingTvSeries = 
      "subscribersUsername" : req.session.username
      "id"                  : req.query.id
    mongodbclient.removeSeriesFromSubscribedTvShows unsubscribingTvSeries, (result) ->
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

app.use express.static __dirname + '/public'

(() ->
  days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  currentDay = days[(new Date()).getDay()]
  subscribers = {}
  mongodbclient.getTvShowsAiringOn currentDay, (result) ->
    console.log "TV Shows Airing on #{currentDay} -\n", result

    for tvShow in result.data
      console.log "show -", tvShow.subscribersUsername
      if !subscribers[tvShow.subscribersUsername]
        subscribers[tvShow.subscribersUsername] = []
      subscribers[tvShow.subscribersUsername].push tvShow

    console.log "subscribers today -\n", subscribers
    return
  return
)()




























