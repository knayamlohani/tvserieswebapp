
mongodbclient  = require './mongodbclient.js'
moment         = require 'moment'
mailer         = require './mailer.js'
exports.performJobs = ->

  setInterval () ->
  ,
  30*60

  #to check for expired account authentication and password reset tokens and delete them from database
  
  
  setInterval () ->
    mongodbclient.deleteExpiredPasswordResetTokens "", (result) ->
      console.log result
      return

    mongodbclient.deleteExpiredAccountAuthenticationTokens "", (result) ->
      console.log result
      return

    return

    mongodbclient.deleteFinishedJobs "", (result) ->
      console.log result
      return

    return
  ,
  10*60*1000
  
  

  ###
    to check if mail subscriptions jobs for today were created
    if not create them
    
    a table(jobs created status) is maintained which keeps track of various jobs like mail subscriptions, mail newslatter, etc
    if there is an entry for mail subscriptions for today in the table, implies mail subscriptions jobs are already created
    else mail subscriptions jobs will be created(ie added to jobs table) and an entry will will be added to jobsCreatedStatus table
    for todays mail subscription jobs

    runs every half and hour
  ###

  
  
  setInterval () ->

    options = 
      "object":
        "type" : "mailSubscriptions"
        "date" : moment.utc().format("MM-DD-YYYY").toString()

    mongodbclient.checkIfJobsCreated options, (result) ->
      
      if !result.err && !result.status
        console.log "jobs not created for today"

        generateJobs moment.utc().format().toString(), (result) ->
          console.log "created mail subscription jobs for today and now adding an entry to jobscreatedstatus table for mailsubscriptions jobs", result
          mongodbclient.addEntryToJobsCreatedStatusCollection options, (result) ->
            console.log "entry added to jobsCreatedStatus collection", result 
            return
          return
      else
        console.log "jobs already created for today"
      return

    return
  ,
  1*60*1000
  



  

  

  ###
  checks every 10 minutes for pending jobs (mailing subscriptions)
  ###

  setInterval () ->
    console.log "sending mailSubscriptions"
    getMailSubscriptionJobsForToday()
    return
  ,
  1*60*1000
  
  
  # function to generate mail subscription jobs
  generateJobs = (utcDateString, callback) ->
  
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    #currentDay = days[(new Date()).getDay()]
    currentDay = days[moment(utcDateString).utc().day()]
    jobs = []

    console.log "currentDay", currentDay
    
    options = 
      "object" :
        "airsOnDayOfWeek" : currentDay

    mongodbclient.getTvShowsAiringOn options, (result) ->
      #console.log "TV Shows Airing on #{currentDay} -\n", result

      

      for tvShow in result.data
        sixAM = moment(utcDateString).utc().hours(6).minutes(0).seconds(0).format().toString()
        

        #secondsToSixAM = (moment(sixAM) - moment(utcDateString))/1000
        #console.log "hours to six am", secondsToSixAM

        #deliveryTime = moment(utcDateString).utc().subtract(tvShow.subscribersTimeZone * 60, 'minutes').add(secondsToSixAM, 'seconds').utc().format().toString()
        
        deliveryTime = moment(sixAM).utc().subtract(tvShow.subscribersTimeZone, 'hours').utc().format().toString()
        #delivery time by GMT 00:00
        job = 
          "email"        : tvShow.subscribersEmail
          "deliveryTime" : deliveryTime
          "status"       : "queue"
          "day"          : tvShow.airsOnDayOfWeek
          "type"         : "mailSubscriptions"

        #if !jobs.contains job
        jobs.push job

      console.log "jobs", jobs
      mongodbclient.addNewJob options =
        "object" : job
      , 
      callback

      return
    return
  


  # function to get subscriptions for today
  getMailSubscriptionJobsForToday = () ->

    utcDate = moment.utc().format()
    console.log "utcDate", utcDate
    utcDateString = utcDate.toString()
    dayOfWeek = getDaysNameFor moment(utcDateString).utc().day()
    console.log "today is", dayOfWeek


    options = 
      "object" : 
        "day"    : dayOfWeek
        "status" : "queue"

    mongodbclient.getMailSubscriptionJobs options, (result) ->
      console.log "result", result
      data = result.data

      for job in result.data
        if moment(utcDateString) - moment(job.deliveryTime) >=0
          ((job) ->
            console.log "mailing subscriptions for", job.email
            mailSubscriptionsFor 
              "email" : job.email
              "day"   : job.day
            ,
            (result) ->
              console.log "mailed subscriptions for ", job.email, "result", result
              mongodbclient.updateDocumentInCollection options = 
                "object":
                  "searchParameter":
                    "email": job.email

                  "updatedValue" :
                    "status": "finished"

                "collection" : "jobs"
              ,
              (result) ->
                console.log "updated job status to finished, result ", result 
                return

              return
            return
          )(job)
      return 

    return


  
  mailSubscriptionsFor = (subscriber, callback) ->
    

    options =
      "object" : 
        "airsOnDayOfWeek"  : subscriber.day
        "subscribersEmail" : subscriber.email

    console.log "mailing subscriptions"

    mongodbclient.getTvShowsAiringOn options, (result) ->
    #console.log "TV Shows Airing on #{currentDay} -\n", result

      #console.log "tv shows for given subscriber are", result.data
      
      subscribers = {}
      allUsers = []
      temp = []

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
      mailer.mailSubscriptions temp, callback
      
      return
      

    return


  #mailSubscriptionsFor "Saturday"

  getDaysNameFor = (dayNo) ->
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    return days[dayNo]

  
  
  return