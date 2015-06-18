
appData = 
	name       : ""
	id         : ""
	banners    : ""
	actors     : []
	data       : {}
	artworkUrl : ""
	host       : "http://tvserieswebapp.herokuapp.com"
	backgroundImageUrl: ""


if Modernizr.localstorage
	appData.name    = localStorage.getItem "series-name"
	appData.id      = localStorage.getItem "series-id"
	appData.banners = JSON.parse localStorage.getItem "series-banners"
else if Modernizr.sessionstorage
	appData.name    = sessionStorage.getItem "series-name"
	appData.id      = sessionStorage.getItem "series-id"
	appData.banners = JSON.parse sessionStorage.getItem "series-banners"
if window.location.href.split('?')[1]
	appData.name 			    		 = decodeURIComponent ((window.location.href.split('?')[1]).split("&")[0]).split('=')[1]
	appData.id   			         = decodeURIComponent ((window.location.href.split('?')[1]).split("&")[1]).split('=')[1]
	appData.artworkUrl         = decodeURIComponent ((window.location.href.split('?')[1]).split("&")[2]).split('=')[1]
	appData.altArtworkUrl      = decodeURIComponent ((window.location.href.split('?')[1]).split("&")[3]).split('=')[1]
	appData.currentArtworkUrl  = appData.artworkUrl
	if window.innerWidth > 504 and window.innerWidth < 1101
		appData.currentArtworkUrl  = appData.altArtworkUrl

app = angular.module 'app', []

#app controller
app.controller 'controller',[ '$scope','$http',($scope,$http) ->
	this.appData = appData
	this.appData.actorsNotDownloaded = true
	this.appBehavior = {}
	this.appData.seriesDataNotDownloaded = true
	this.appData.seriesSubscriptionStatus = false
	this.appData.seriesSubscriptionStatusDownloaded = false
	series = this.appData
	series.castAvailable = true

	this.appBehavior.getCastAvailabilityCurrently = ->
		series.actors!=[0]


  

#for testing storing the data to localstorage
	#if localstorage.getItem "series-data"

	url = "/series/seriesId/#{series.id}/seriesOnly"
		#gets json
	$http.get(url).success((data) ->
		series.data = data
		series.seriesDataNotDownloaded = false
		console.log "series data downloaded"

		#finding the coming up
		series.data.comingUp = {}
		for season in series.data.seasons
			for episode in season.episodes
				if (new Date()).setHours(0,0,0,0) <= (new Date(episode.airDate)).setHours(0,0,0,0)
				  series.data.comingUp = episode
				  break

		if !appData.actorsNotDownloaded && appData.seriesSubscriptionStatusDownloaded
			progressBar = $("#request-progress-bar .progress-bar")
			progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
			progressBar.addClass "progress-bar-success"
			
	)

	if !series.artworkUrl
		url = "/series/seriesId/#{series.id}/banners"
		#gets json
		$http.get(url).success((data) ->
			series.banners = data
			artworkFound = false
			backgroundFound = false
			for banner in series.banners
				if artworkFound and backgroundFound
					break
				if banner.type == "poster" and !artworkFound
					series.artworkUrl = banner.url
					if window.innerWidth < 505 or window.innerWidth > 1100
						series.currentArtworkUrl = series.artworkUrl
					artworkFound = true
					
				if banner.type == "fanart" and !backgroundFound
					series.backgroundImageUrl = banner.url
					backgroundFound = true


			$('#blur-layer').css "background", "#fafafa url(#{appData.artworkUrl}) 0 0 / cover"
			$('body').css "background", "#fafafa url(#{appData.artworkUrl}) 0 0 / cover"

		)
	else
		$('#blur-layer').css "background", "#fafafa url(#{appData.artworkUrl}) 0 0 / cover"
		$('body').css "background", "#fafafa url(#{appData.artworkUrl}) 0 0 / cover"

	if series.actors.length == 0
		url = "/series/seriesId/#{series.id}/actors"
		$http.get(url).success (data) ->
			series.actors = data
			if series.actors.length == 0
				appData.castAvailable = false
			appData.actorsNotDownloaded = false

			if !appData.seriesDataNotDownloaded && appData.seriesSubscriptionStatusDownloaded
				console.log "appdata is", appData.data
				progressBar = $("#request-progress-bar .progress-bar")
				progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
				progressBar.addClass "progress-bar-success"




  $scope.globalClick = false
]

app.directive 'episodeDirective', ['$timeout', ($timeout)->
	(scope, element, attrs) ->
		$timeout ->
			scope.$apply ->
	    	if !scope.episode.name or scope.episode.name == "TBA"
	    		scope.episode.name = "To Be Anounced"
	    	return

    $(angular.element(element)).click ->
      $('.episode-title').not($(this)).removeClass 'selected'
      $(this).toggleClass 'selected'
      $('.episode-title').not($(this)).parent().find('.episode-body').addClass 'display-none'
      episodeBody = $(this).parent().find('.episode-body')
      episodeBody.toggleClass 'display-none'


      if navigator.platform != "MacIntel" and !episodeBody.hasClass 'nice-scrolled' and !episodeBody.hasClass 'display-none'
      	console.log navigator.platform == "MacIntel"
      	episodeBody.niceScroll()
      	episodeBody.addClass 'nice-scrolled'
      return
    return
 ]

app.directive 'actorTemplate', ->
	restrict : 'E'
	templateUrl: 'templates/actor-template.html'

app.directive 'seasonDirective', ->
	(scope, element, attrs) ->
    seasonNumber = scope.$index
    episodesCount =  +appData.data.seasons[seasonNumber].episodes.length 
    if episodesCount%2==0
    	episodesCount/=2
    else
    	episodesCount= episodesCount/2 +1
    
    return

app.filter 'sliceFirstHalf', ->
  (arr) ->
  	if arr.length %2 == 1
  		end = (arr.length + 1)/2
  	else end =arr.length/2
  	(arr || []).slice(0, end);

app.filter 'sliceSecondHalf', ->
	(arr) ->
		if arr.length%2 == 0
	  		start = arr.length/2 
	  	else start = (arr.length+1)/2 
		(arr || []).slice( start, arr.length);

app.directive 'blurLayerDirective', ->
	(scope, element, attrs) ->

app.directive 'allSeasonsDirective', ->
	(scope, element, attrs) ->
		window.setTimeout () ->
			height = +$('#series').css('height').split('px')[0] # +  +$('#seasons-container').css('height').split('px')[0]
			console.log height
			$('#blur-layer').css("height", height)
		,
		10000


app.directive 'seriesOverviewBodyDirective', ['$timeout', ($timeout)->
	(scope, element, attrs) ->
		if navigator.platform != "MacIntel" and !$('#overview-body').hasClass 'nice-scrolled'
			element.niceScroll()
			element.addClass 'nice-scrolled'
]


app.directive 'actorDescriptionDirective', ->
	link: (scope, element, attrs) ->
		console.log "actor-description"
		if navigator.platform != "MacIntel" and !element.hasClass 'nice-scrolled'
			element.niceScroll()
			element.addClass 'nice-scrolled'
		return

app.directive 'allActorsDirective',[ '$timeout', ($timeout) ->
	link: (scope, element, attrs) ->
		$timeout ->
			console.log " cast "+ appData.actors
		if appData.actors.length == 0
			console.log "no cast details"
		
		return
]


app.directive 'seriesSubscriptionDirective',[ '$http', ($http) ->
	#resetting the request-ptogress-bar
			
	link: (scope, element, attrs) ->

		#getting series subscription status
		$http.get("/subscriptions/getSeries?id=#{appData.id}").success (result) ->
			appData.seriesSubscriptionStatusDownloaded = true
			console.log "series subscription status is", result
			appData.seriesSubscriptionStatus = result.status
			console.log "status", appData.seriesSubscriptionStatus
			#if result.status == false 
			#$(element).find("i").removeClass "visibility-hidden"

			$("#subscribe,#unsubscribe").addClass "visibility-hidden"
			
			
			if appData.seriesSubscriptionStatus
				$("#unsubscribe").removeClass "visibility-hidden"
			else
				$("#subscribe").removeClass "visibility-hidden"

			
			#else $(element).find("i").addClass "visibility-hidden"



			if !appData.seriesDataNotDownloaded && !appData.actorsNotDownloaded
				progressBar = $("#request-progress-bar .progress-bar")
				progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
				progressBar.addClass "progress-bar-success"
			###
			progressBar = $("#request-progress-bar .progress-bar")
			if result.err
				progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
				progressBar.addClass "progress-bar-danger"
			else
				progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
				progressBar.addClass "progress-bar-success"
			###
			return



		$(element).find(">a").on 'click', (e) ->
			e.preventDefault()
			
			
			console.log "clicking", appData.seriesSubscriptionStatus
			
			#resetting the request-ptogress-bar
			$("#request-progress-bar").removeClass "display-none"
			$("#request-progress-bar .progress-bar").removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
			$("#request-progress-bar .progress-bar").addClass "progress-bar-striped"
			
			progressBar = $("#request-progress-bar .progress-bar")
			if !appData.seriesSubscriptionStatus
				console.log "subscribing series ", appData.name
				$http.get("/subscribe?name=#{appData.name}&id=#{appData.id}&artworkUrl=#{appData.artworkUrl}&airsOnDayOfWeek=#{appData.data.airsOnDayOfWeek}").success (result) ->
					console.log "result", result
					
					if result.err
						progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
						progressBar.addClass "progress-bar-danger"
						$("#not-signedin-error").modal()
					else
						appData.seriesSubscriptionStatus = true
						progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
						progressBar.addClass "progress-bar-success"

						$("#subscribe,#unsubscribe").addClass "visibility-hidden"
						$("#unsubscribe").removeClass "visibility-hidden"
					return
			else
				console.log "unsubscribing the series"
				$http.get("/unsubscribe?id=#{appData.id}").success (result) ->
					console.log "result", result
					if result.err
						progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
						progressBar.addClass "progress-bar-danger"
						$("#not-signedin-error").modal()
					else
						appData.seriesSubscriptionStatus = false
						progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
						progressBar.addClass "progress-bar-success"

						$("#subscribe,#unsubscribe").addClass "visibility-hidden"
						$("#subscribe").removeClass "visibility-hidden"
					return



			return
		return
]
		
app.directive 'searchMoreSeriesDirective', [ '$http', '$timeout', ($http, $timeout) ->
	link: (scope, element, attrs ) ->
		scope.search = 
			"query"     : ""
			"results"   : []
			"makeQuery" : () ->
				
				query = encodeURIComponent scope.search.query
				url = "/series/seriesName/#{query}"

				console.log "url", url
				$http.get(url).success (data) ->
					console.log "results", data
					scope.search.results = data.seriesArray;
					return

				return
		return 
]

$(window).ready ->
	if navigator.platform != "MacIntel"
	  $("html").niceScroll()

	height = screen.height
	width  = screen.width
	$('body').css "font-size", "#{15/1280*width}px"


	$("#search-more-series").on 'click', (e) ->
		$("#search-more-series #search-section").toggleClass 'hidden'

	$("#search-more-series input").on 'click', (e) ->
		e.stopPropagation()
		return

	return

$(window).resize ->
	scope = angular.element('body').scope()
	if window.innerWidth > 504 and window.innerWidth < 1101
		scope.$apply ->
			scope.appController.appData.currentArtworkUrl = appData.altArtworkUrl
			return
	else 
		scope.$apply ->
			scope.appController.appData.currentArtworkUrl = appData.artworkUrl
			return
	return





