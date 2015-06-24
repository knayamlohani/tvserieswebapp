
mongodbclient  = require './mongodbclient.js'
moment         = require 'moment'
mailer         = require './mailer.js'
request        = require 'request'
http           = require 'http'
host= ""
exports.setHost = (hostName) ->
  host = hostName
  console.log "host set", host
  return
exports.performJobs = ->

  ###
    deletes the expired or finished entries in various collections from the database  
  ###
  
  
  deleteExpiredAndFinishedEntriesInCollectionsSubroutine = () ->
    console.log "calling deleteExpiredAndFinishedEntriesInCollectionsSubroutine"
    ###

    ###
    mongodbclient.deleteExpiredPasswordResetTokens "", (result) ->
      console.log "deleteExpiredPasswordResetTokens result", result
      return

    ###
    
    ###
    mongodbclient.deleteExpiredAccountAuthenticationTokens "", (result) ->
      console.log "deleteExpiredAccountAuthenticationTokens result", result
      return

    ###
    
    ###
    
    ###
    mongodbclient.deleteEntriesFromJobsCollectionWithStatusFinished options =
      "collection" : ""
    , 
    (result) ->
      console.log "deleteEntriesFromJobsCollectionWithStatusFinished result", result
      return
    ###
   

    ###
    
    ###

    ###
    mongodbclient.deleteExpiredJobsCreatedStatusCollectionEntries options =
      "collection" : ""
    , 
    (result) ->
      console.log "deleteExpiredJobsCreatedStatusCollectionEntries result", result
      return
    ###
    return

  deleteExpiredAndFinishedEntriesInCollectionsSubroutine()
  setInterval deleteExpiredAndFinishedEntriesInCollectionsSubroutine, 30*60*1000
  


  ###
    to check if mail subscriptions jobs for today were created
    if not create them
    
    a table(jobs created status) is maintained which keeps track of various jobs like mail subscriptions, mail newslatter, etc
    if there is an entry for mail subscriptions for today in the table, implies mail subscriptions jobs are already created
    else mail subscriptions jobs will be created(ie added to jobs table) and an entry will will be added to jobsCreatedStatus table
    for todays mail subscription jobs

    runs every half and hour
  ###

  checkIfJobsCreatedSubroutine = () ->
    console.log "calling checkIfJobsCreatedSubroutine"
    #console.log "date:", moment.utc().hours(0).minutes(0).seconds(0).format().toString()
    #console.log "date:", moment.utc().format()
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

  checkIfJobsCreatedSubroutine()
  setInterval checkIfJobsCreatedSubroutine, 2*60*1000

  

  

  ###
  checks every 10 minutes for pending jobs (mailing subscriptions)
  ###

  mailSubscriptionsSubroutine = () ->
    console.log "calling mailSubscriptions subroutine"

    getMailSubscriptionJobsForToday()
    return

  setInterval mailSubscriptionsSubroutine, 1*60*1000
  
  



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

      if !result.err

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

        console.log "jobs entries", jobs
        
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
    console.log "utcdatestring", utcDateString
    dayOfWeek = getDaysNameFor moment(utcDateString).utc().day()
    console.log "today is", dayOfWeek


    options = 
      "object" : 
        "day"    : dayOfWeek
        "status" : "queue"

    mongodbclient.getMailSubscriptionJobs options, (result) ->
      console.log "result", result
      if !result.err
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
                      "_id"  : job["_id"]

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


  
  mailSubscriptionsFor2 = (subscriber, callback) ->
    

    options =
      "object" : 
        "airsOnDayOfWeek"  : subscriber.day
        "subscribersEmail" : subscriber.email

    #console.log "date:", moment.utc().hours(0).minutes(0).seconds(0).format().toString()

    console.log "mailing subscriptions"

    mongodbclient.getTvShowsAiringOn options, (result) ->
    #console.log "TV Shows Airing on #{currentDay} -\n", result

      #console.log "tv shows for given subscriber are", result.data
      if !result.err

        subscribers = {}
        allUsers = []
        temp = []

        episodesAiringForSeriesWithIdToday = []
        tvShowsCount = result.data.length
        counter = 0;

        for tvShow in result.data
          counter++
          if !subscribers[tvShow.subscribersUsername]
            subscribers[tvShow.subscribersUsername] = {}
            subscribers[tvShow.subscribersUsername].tvShows = []
            subscribers[tvShow.subscribersUsername].email = tvShow.subscribersEmail
            subscribers[tvShow.subscribersUsername].username = tvShow.subscribersUsername
            subscribers[tvShow.subscribersUsername].name = tvShow.subscribersFirstName + " " + tvShow.subscribersLastName
            allUsers.push tvShow.subscribersUsername


          #checking if the tvshow actually airs today
          options = 
            "url" : "https://#{host}/seriesWithId=#{tvShow.id}/episodeWithAirDate=#{moment.utc().format('DD-MM-YYYY')}"

          
          #options.url = "https://#{host}/seriesWithId=#{tvShow.id}/episodeWithAirDate=#{moment.utc().format('DD-MM-YYYY')}"
          #console.log "options", options
          
          request options.url, (error, response, body) ->
            console.log "request", body
            return




          subscribers[tvShow.subscribersUsername].tvShows.push 
            "name"        : tvShow.name
            "id"          : tvShow.id
            "artworkUrl"  : tvShow.artworkUrl
            "episodeName" : ""

        console.log "subscribers today -\n", JSON.stringify subscribers, null, 4
        usersCount = allUsers.length
        
        for user in allUsers
          temp.push
            "email"    : subscribers[user].email
            "name"     : subscribers[user].name
            "username" : subscribers[user].username
            "tvShows"  : subscribers[user].tvShows
        
        console.log JSON.stringify temp, null, 4
        #mailer.mailSubscriptions temp, callback
      
      return
      

    return

  mailSubscriptionsFor = (subscriber, callback) ->
    

    options =
      "object" : 
        "airsOnDayOfWeek"  : subscriber.day
        "subscribersEmail" : subscriber.email

    #console.log "date:", moment.utc().hours(0).minutes(0).seconds(0).format().toString()

    console.log "mailing subscriptions"

    mongodbclient.getTvShowsAiringOn options, (result) ->
    #console.log "TV Shows Airing on #{currentDay} -\n", result

      #console.log "tv shows for given subscriber are", result.data
      if !result.err

        subscribers = {}
        allUsers = []
        temp = []
        today = null

        episodesAiringForSeriesWithIdToday = []
        tvShowsCount = result.data.length
        counter = 0;

        for tvShow in result.data
          
          if !subscribers[tvShow.subscribersUsername]
            subscribers[tvShow.subscribersUsername] = {}
            subscribers[tvShow.subscribersUsername].tvShows = []
            subscribers[tvShow.subscribersUsername].email = tvShow.subscribersEmail
            subscribers[tvShow.subscribersUsername].username = tvShow.subscribersUsername
            subscribers[tvShow.subscribersUsername].name = tvShow.subscribersFirstName + " " + tvShow.subscribersLastName
            allUsers.push tvShow.subscribersUsername


          

          
          #options.url = "https://#{host}/seriesWithId=#{tvShow.id}/episodeWithAirDate=#{moment.utc().format('DD-MM-YYYY')}"
          #console.log "options", options
          ((tvShow) ->
            #checking if the tvshow actually airs today
            if !today
              today = moment.utc()

            options = 
              "url" : "https://#{host}/seriesWithId=#{tvShow.id}/episodeWithAirDate=#{today.format('DD-MM-YYYY')}"
            
            request options.url, (error, response, body) ->
              counter++
              episode = JSON.parse body
              console.log "request", episode.number, " ", episode.name

              

              if moment.utc(episode.airDate).format('DD-MM-YYYY') == today.format('DD-MM-YYYY')
                console.log "request", episode
                subscribers[tvShow.subscribersUsername].tvShows.push 
                  "name"        : tvShow.name
                  "id"          : tvShow.id
                  "artworkUrl"  : tvShow.artworkUrl
                  "episodeName" : "S#{if episode.season < 10 then 0 else ''}#{episode.season}E#{if episode.number < 10 then 0 else ''}#{episode.number} #{episode.name}"
                  

              if counter == tvShowsCount
                console.log "subscribers today -\n", JSON.stringify subscribers, null, 4
                usersCount = allUsers.length
                
                for user in allUsers
                  temp.push
                    "email"    : subscribers[user].email
                    "name"     : subscribers[user].name
                    "username" : subscribers[user].username
                    "tvShows"  : subscribers[user].tvShows
                    "airDay"   : getDaysNameFor today.day()
                    "noTvShows": if subscribers[user].tvShows.length == 0 then true else false

                console.log "airing today", JSON.stringify temp, null, 4
                mailer.mailSubscriptions temp, callback
              return
            return
          )(tvShow)


          ###
          subscribers[tvShow.subscribersUsername].tvShows.push 
            "name"        : tvShow.name
            "id"          : tvShow.id
            "artworkUrl"  : tvShow.artworkUrl
            "episodeName" : ""
          ###

         ### 
        console.log "subscribers today -\n", JSON.stringify subscribers, null, 4
        usersCount = allUsers.length
        
        for user in allUsers
          temp.push
            "email"    : subscribers[user].email
            "name"     : subscribers[user].name
            "username" : subscribers[user].username
            "tvShows"  : subscribers[user].tvShows
        ###
        console.log JSON.stringify temp, null, 4
        #mailer.mailSubscriptions temp, callback
      
      return
      

    return

  #mailSubscriptionsFor "Saturday"

  getDaysNameFor = (dayNo) ->
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    return days[dayNo]

  makeHttpGetRequest = (options, callback) ->
    console.log "making http request", options.url
    request options.url, (error, response, body) ->
      console.log "episode body", body
      return
    return
    
  
  return