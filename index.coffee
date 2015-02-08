tvdbWebService = require 'tvdbwebservice'
express = require 'express'
app = express()

app.set 'port', (process.env.PORT || 5000)
app.set 'tvdbApiKey', (process.env.TVDB_API_KEY)
app.use express.static __dirname + '/public' ;


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

app.use (req, res, next) -> 
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"
  next()
  return

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

app.get '/', (req, res)  ->
  res.end 'Welcome to tvserieswebserver'
  return

app.listen app.get('port') , ->
  console.log "Node app is running at" + app.get 'port'
  return

###
app.get '/signup', (req, res)  ->
  res.end 'Welcome to signup page'
  return
###





app.post '/signup', (req, res)  ->
  mongodbclient.addNewUser
    "first-name" : req.body['first-name']
    "last-name"  : req.body['last-name']
    "username"   : req.body['username']
    "email"      : req.body['email']
    "password"   : req.body['password']
  ,
  (user) ->
    req.session.username = user.username
    req.session.password = user.password
    req.session.email = user.email
    req.session["signin-status"] = true

    res.redirect('/')
    return


app.get '/signin-status', (req, res) ->
  if req.session.username
    req.session["signin-status"] = true
  else req.session["signin-status"] = false
  
  res.end JSON.stringify
    "first-name"    : req.session["first-name"]
    "email"         : req.session["email"]
    "username"      : req.session["username"]
    "signin-status" : req.session["signin-status"]
  return

app.get '/signout', (req, res) ->
  req.session.destroy (err) ->
    res.redirect('/')
    return
  return

app.post '/signin', (req, res) ->
  mongodbclient.authenticateUserCredentials req.body.email, req.body.password, (userCredentials) ->
    req.session.username = userCredentials.username
    req.session["signin-status"] = userCredentials["signin-status"]
    #res.redirect('/')
    rrs.end()
    return
  return
  









