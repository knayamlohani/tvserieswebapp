path           = require 'path'
templatesDir   = path.resolve __dirname, 'templates'
emailTemplates = require 'email-templates'
nodemailer     = require 'nodemailer'
crypto         = require 'crypto'
mongodbclient  = require './mongodbclient.js'

emailAccount = 
  "username": null
  "password": null

exports.setEmailAccount = (account) ->
  emailAccount.username = account.username
  emailAccount.password = account.password
  return

host= ""
exports.setHost = (hostName) ->
  host = hostName
  console.log "host set", host
  return

exports.mailSubscriptions = (subscribers, callback) -> 

  emailTemplates templatesDir, (err, template) ->
    console.log "email templates"

    if err
      console.log(err);
    else
      console.log "no error"
      transportBatch = nodemailer.createTransport("SMTP", {
        service: "Gmail",
        auth: {
          user: emailAccount.username,
          pass: emailAccount.password
        },
        debug: true
      });

      users = subscribers

      Render = (locals) ->
        #console.log "Render"
        this.locals = locals

        this.send = (err, html, text) ->
          if err
            console.log err
          else 
            console.log "transportBatch"
            transportBatch.sendMail
              from: 'TV Series <tvserieswebapp@gmail.com>'
              to: locals.email
              subject: 'TV Shows airing today'
              html: html
              generateTextFromHTML: true
              text: text
            , 
            (err, responseStatus) ->
              if err
                console.log err
              else
                console.log responseStatus.message


              callback 
                "err"    : err
                "status" : ""
                "data"   : responseStatus
              
              return
          
          return
        
        this.batch = (batch) ->
          #console.log "called batch"
          batch this.locals, templatesDir, this.send
          return
        return
        

      # Load the template and send the emails 
      template 'subscriptions', true, (err, batch) ->
        #console.log "subscriptions"

        for user in users
          #console.log("sending mail")
          render = new Render user;
          render.batch batch;
            
        return

    return
  return

exports.mailPasswordResetLinkTo = (email) ->
  console.log "sending password reset link"
  generateToken email, generateHashFromTokenAndMailResetLink
  return

generateToken = (email, callback) ->
  crypto.randomBytes 32, (ex, buf) ->
    token = buf.toString 'hex'
    callback email, token
    return
  return


generateHashFromTokenAndMailResetLink = (email, token) ->
  shasum = crypto.createHash 'sha1'
  shasum.update token
  hashValue = shasum.digest 'hex'



  console.log "token", token
  console.log "hashValue", hashValue
  console.log "email", email

  expires = new Date()
  expires.setMinutes expires.getMinutes() + 30
  mongodbclient.storePasswordChangeRequest 
    "token"   : hashValue
    "expires" : expires
    "email"   : email
  ,
    (data) ->
      console.log "reset password data", data
      return

  transporter = nodemailer.createTransport 'SMTP',
    service: 'Gmail',
    auth:
      user: emailAccount.username,
      pass: emailAccount.password

 
  # setup e-mail data with unicode symbols 

  body = "<a href='https://#{host}/resetPassword?token=#{token}'> http://#{host}/resetPassword?token=#{token} </a>"
  mailOptions =
    from    : 'TV Series <tvserieswebapp@gmail.com>'
    to      : email
    subject : 'Reset password'
    text    : 'Click the link below to reset your password' 
    html    : body
  
  # send mail with defined transport object 
  transporter.sendMail mailOptions, (error, info) ->
    if error
      console.log error
    else
      console.log 'Message sent: ' + JSON.stringify info
    
    return
  


  return

exports.sendMail = (mailOptions, callback) ->
  transporter = nodemailer.createTransport 'SMTP',
    service: 'Gmail',
    auth:
      user: emailAccount.username,
      pass: emailAccount.password

  
  # send mail with defined transport object 
  transporter.sendMail mailOptions, (error, info) ->
    if error
      console.log error
    else
      console.log 'Message sent: ' + JSON.stringify info

    callback
      "err"   : error
      "status": if error then true else false
      "data"  : info
    
    return
  
  return




