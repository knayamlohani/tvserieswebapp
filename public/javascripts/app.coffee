
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
	series = this.appData


  

#for testing storing the data to localstorage
	#if localstorage.getItem "series-data"

	url = "#{series.host}/series/seriesId/#{series.id}/seriesOnly"
		#gets json
	$http.get(url).success((data) ->
		series.data = data
		#console.log series
		#localstorage.setItem "series-data", data
	)
	#else series.data = localstorage.getItem "series-data"



	if !series.artworkUrl
		url = "#{series.host}/series/seriesId/#{series.id}/banners"
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
		url = "#{series.host}/series/seriesId/#{series.id}/actors"
		$http.get(url).success((data) ->
			series.actors = data
		)
  $scope.globalClick = false
]
.directive 'episodeDirective', ->
  (scope, element, attrs) ->
    $(angular.element(element)).click ->
      $('.episode-title').not($(this)).removeClass 'selected'
      $(this).toggleClass 'selected'
      $('.episode-title').not($(this)).parent().find('.episode-body').addClass 'display-none'
      episodeBody = $(this).parent().find('.episode-body')
      episodeBody.toggleClass 'display-none'
      if navigator.platform != "MacIntel" and !episodeBody.hasClass 'nice-scrolled' and !episodeBody.hasClass 'display-none'
      #if !episodeBody.hasClass 'display-none' and !episodeBody.hasClass 'nice-scrolled'
      	console.log navigator.platform == "MacIntel"
      	episodeBody.niceScroll()
      	episodeBody.addClass 'nice-scrolled'
      return
    return
.directive 'actorTemplate', ->
	restrict : 'E'
	templateUrl: 'templates/actor-template.html'
.directive 'seasonDirective', ->
	(scope, element, attrs) ->
    seasonNumber = scope.$index
    episodesCount =  +appData.data.seasons[seasonNumber].episodes.length 
    if episodesCount%2==0
    	episodesCount/=2
    else
    	episodesCount= episodesCount/2 +1
    
    #$(angular.element(element)).find('.season-body').css "height","#{episodesCount * 1.6 }em"
    return
###
app.filer 'sliceFirstHalf', ->
	(arr,center) ->
		console.log (arr || []).slice(0, center.length()/2)
		(arr || []).slice(0, center.length()/2)
###
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
		console.log height
		$('#blur-layer').css "height", height
app.directive 'seriesOverviewBodyDirective', ->
	(scope, element, attrs) ->
		if navigator.platform != "MacIntel" and !$('#overview-body').hasClass 'nice-scrolled'
			$('#overview-body').niceScroll()
			$('#overview-body').addClass 'nice-scrolled'
app.directive 'actorDescriptionDirective', ->
	link: (scope, element, attrs) ->
		console.log "actor-description"
		if navigator.platform != "MacIntel" and !$('.actor-description').hasClass 'nice-scrolled'
			$('.actor-description').niceScroll()
			$('.actor-description').addClass 'nice-scrolled'
		return
		






