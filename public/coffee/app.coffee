
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
	appData.name = decodeURIComponent ((window.location.href.split('?')[1]).split("&")[0]).split('=')[1]
	appData.id   = decodeURIComponent ((window.location.href.split('?')[1]).split("&")[1]).split('=')[1]

app = angular.module 'app', []

#app controller
app.controller 'controller',[ '$scope','$http',($scope,$http) ->
	this.appData = appData
	this.appData.actorsNotDownloaded = true
	this.appBehavior = {}
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
		#console.log series
		#localstorage.setItem "series-data", data
	)
	#else series.data = localstorage.getItem "series-data"



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
					artworkFound = true
					
				if banner.type == "fanart" and !backgroundFound
					series.backgroundImageUrl = banner.url
					backgroundFound = true
			$('#blur-layer').css "background", "#fafafa url(#{appData.artworkUrl}) 0 0 / cover"
			$('body').css "background", "#fafafa url(#{appData.artworkUrl}) 0 0 / cover"

		)
		
	if series.actors.length == 0
		url = "/series/seriesId/#{series.id}/actors"
		$http.get(url).success (data) ->
			series.actors = data
			if series.actors.length == 0
				appData.castAvailable = false
			appData.actorsNotDownloaded = false
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
		height = +$('#series').css('height').split('px')[0]  +  +$('#seasons-container').css('height').split('px')[0]
		$('#blur-layer').css "height", height


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
	link: (scope, element, attrs) ->
		$(element).find(">a").on 'click', (e) ->
			e.preventDefault()
			console.log "subscribing series ", appData.name
			
			$http.get("/subscribe?name=#{appData.name}&id=#{appData.id}&artworkUrl=#{appData.artworkUrl}").success (data) ->
				console.log "status", data
				return
			
			return
		return
]
		

$('window').ready ->
	if navigator.platform != "MacIntel"
	  $("html").niceScroll()

	height = screen.height
	width  = screen.width
	$('body').css "font-size", "#{15/1280*width}px"





