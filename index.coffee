tvdbWebService = require 'tvdbwebservice'
express = require 'express'
app = express()

fs = require "fs"
path = require 'path'
http = require 'http'
handlebars = require "handlebars"




user = 
  "first-name"     : ""
  "last-name"      : ""
  "username"       : ""
  "email"          : ""
  "signin-status"  : false
  "sigin-page"     : ""
  "dashboard-page" : ""


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
    "ttl" : 7*24*60*60*1000
  "cookie" : 
    "maxAge" : 7*24*60*60*1000


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


###================================================================================================
Routs
================================================================================================###


###
app.use (req, res, next) -> 
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"
  next()
  return
###



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





#routs to access the app

app.get '/', (req, res)  ->  
  console.log "requesting series homepage"
  
  if !indexTemplate
    indexHTML = fs.readFileSync "public/index.html", "utf8"
    indexTemplate = handlebars.compile(indexHTML)
  
  user = 
    "firstName"     : ""
    "lastName"      : ""
    "username"      : ""
    "email"         : ""
    "signinStatus"  : false
    "signinPage"    : "/signin"
    "dashboardPage" : ""
    "status"        : "Sign in"
    "toggle"        : ""




  if req.session.username
    user = 
      "firstName"     : req.session["firstName"]
      "lastName"      : req.session["lastName"]
      "username"      : req.session.username
      "email"         : req.session.email
      "signinStatus"  : true
      "signinPage"     : ""
      "dashboardPage" : "/dashboard"
      "status"        : req.session.username
      "toggle"        : "dropdown"

  
  result = indexTemplate user

  console.log "account:", user

  res.writeHead 200, {"Context-Type": "text/html"}
  res.write result
  res.end()

  return




app.get '/series.html', (req, res)  ->
  console.log 'requesting series'
  if !seriesHTML
    indexHTML = fs.readFileSync "public/series.html", "utf8"
  
  user = 
    "firstName"     : ""
    "lastName"      : ""
    "username"      : ""
    "email"         : ""
    "signinStatus"  : false
    "signinPage"    : "/signin"
    "dashboardPage" : ""
    "status"        : "Sign in"
    "toggle"        : ""

  if req.session.username
    user = 
      "firstName"     : req.session["firstName"]
      "lastName"      : req.session["lastName"]
      "username"      : req.session.username
      "email"         : req.session.email
      "signinStatus"  : true
      "signinPage"     : ""
      "dashboardPage" : "/dashboard"
      "status"        : req.session.username
      "toggle"        : "dropdown"

  template = handlebars.compile seriesHTML
  result = template user

  res.writeHead 200, {"Context-Type": "text/html"}
  res.write result 
  res.end()

  return



app.post '/signup', (req, res)  ->
  console.log "signing up th user"

  req.session["firstName"] = ""
  req.session["lastName"] = ""
  req.session.username = ""
  req.session.email    = ""
  req.session["signinStatus"] = false

  mongodbclient.checkIfAlreadyRegistered req.body.email, (alreadyRegistered) ->
    if !alreadyRegistered
      mongodbclient.addNewUser
        "firstName" : req.body["firstName"]
        "lastName"  : req.body["lastName"]
        "username"  : req.body["username"]
        "email"     : req.body["email"]
        "password"  : req.body["password"]   
      ,
      (user) ->
        req.session["firstName"]    = user["firstName"]
        req.session["lastName"]     = user["lastName"]
        req.session.username        = user.username
        req.session.email           = user.email
        req.session["signinStatus"] = true
        res.redirect '/'
        return
    else
      res.redirect '/signup' 
    return
  return

app.get '/signup', (req, res) ->


app.get '/signin-status', (req, res) ->
  if req.session.username
    req.session["signin-status"] = true
  else req.session["signin-status"] = false
  
  res.end JSON.stringify
    "firstName"    : req.session["firstName"]
    "email"         : req.session["email"]
    "username"      : req.session["username"]
    "signinStatus" : req.session["signinStatus"]
  return

app.get '/signout', (req, res) ->
  req.session.destroy (err) ->
    res.redirect '/' 
    return
  return




app.get '/signin', (req, res) ->
  console.log "signin get================================================="
  res.writeHead 200, {"Context-Type": "text/html"}
  user = 
    "email": ""
    "errorMessage": ""

  if !signinTemplate
    signinHTML = fs.readFileSync "public/signin.html", "utf8"
    signinTemplate = handlebars.compile signinHTML
  result = signinTemplate user
  res.write result
  res.end()
  return





app.post '/signin', (req, res) ->
  console.log "signin route+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  mongodbclient.authenticateUserCredentials req.body.email, req.body.password, (user) ->

    req.session.username = user.username
    req.session["firstName"] = user.firstName
    req.session["lastName"] = user.lastName
    req.session["email"] = user.email
    req.session["username"] = user.username
    console.log "user", user


    req.session["signinStatus"] = user["signinStatus"]
    
    if req.session["signinStatus"]
      res.redirect '/' 
    else 
      res.writeHead 200, {"Context-Type": "text/html"}
      if !signinTemplate
        signinHTML = fs.readFileSync "public/account/signin.html", "utf8"
        signinTemplate = handlebars.compile signinHTML

      user["errorMessage"] = "Either the username or password you entered is wrong"
      result = signinTemplate user
      res.write result
      res.end()
    return
  return

app.get '/dashboard', (req, res) ->
  console.log "requesting dashboard"
  if !req.session["signinStatus"]
    res.redirect '/signin'
  else 
    user = 
      "firstName"     : req.session["firstName"]
      "lastName"      : req.session["lastName"]
      "username"      : req.session.username
      "email"         : req.session.email
      "signinStatus"  : true
      "signinPage"     : ""
      "dashboardPage" : "/dashboard"
      "status"        : req.session.username
      "toggle"        : "dropdown"
    res.writeHead 200, {"Context-Type": "text/html"}
    if !dashboardTemplate
      dashboardHTML = fs.readFileSync "public/account/dashboard.html", "utf8"
      dashboardTemplate = handlebars.compile dashboardHTML
    result = dashboardTemplate user
    res.write result
    res.end()



  
app.use express.static __dirname + '/public'





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



