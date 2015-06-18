
searchQuery = ""

$('window').ready ->
	$('body').css "font-size", "#{15/1280*screen.width}px"
	if navigator.platform != "MacIntel"
		$("html").niceScroll()

	$('#search-field').on 'focus', (e) ->
		# displaying the exit button for distraction free search mode
		$('#close-distraction-free-search-mode i').removeClass 'display-none'
		

		$('#search-field').removeClass "animate-search-field restore-search-field"
		$('#div-blur-layer').removeClass "animate-blur-layer restore-blur-layer"
		$('#div-search-section').removeClass "animate-search-section restore-search-section"


		$('#search-field').addClass "animate-search-field"
		$('#div-blur-layer').addClass "animate-blur-layer"
		$('#div-search-section').addClass 'animate-search-section'
		return

	$('#close-distraction-free-search-mode i').on 'click', (event) ->
		$('.progress-indicator').toggleClass 'display-none'
		$(this).toggleClass "display-none"
		$('#div-search-section').addClass 'restore-search-section'
		$('#search-field').addClass "restore-search-field"
		$('#div-blur-layer').addClass "restore-blur-layer"
		$('#search-results-container').empty()
		# window.setTimeOut $('#div-blur-layer').addClass "remove-blur-layer-background", 400
		return

	$('#search-field').on 'keyup', (event) ->
		if event.keyCode == 13
			$('.progress-indicator').removeClass 'display-none'
			console.log "search"
		return

searchApp = angular.module 'search-app', []
searchApp.controller 'controller', [ '$scope','$http', ($scope, $http) ->
	$scope.appData = {}
	$scope.appBehavior = {}
	$scope.appData.allSearchResultsData = []
	#$scope.appData.host = "http://tvserieswebapp.herokuapp.com" 
	$scope.appData.progressIndicatorStatus = false
	$scope.appData.currentArtworkUrl = ""

	$scope.appData.searchRequestCompletedStatus = false

	$scope.appData.user =
		"first-name" : ""
		"email"      : ""
		"username"   : ""
		"signed-in"  : ""

	
	$scope.appBehavior.onKeyUp = (event) ->
		if event.keyCode == 13 
		  console.log $scope.appData.searchQuery
		  $scope.appData.progressIndicatorStatus=true

		  $scope.appData.searchRequestCompletedStatus = false
		  searchQuery = encodeURIComponent $scope.appData.searchQuery
		  url = "/series/seriesName/#{searchQuery}"
		  
		  $http.get(url).success (data) ->
		  	$scope.appData.progressIndicatorStatus = false
		  	
		  	
		  	if data.seriesArray
		  		currentSearchResultsData = {"currentSearchQuery"   : $scope.appData.searchQuery,"currentSearchResults" : []}

		  		$scope.appData.allSearchResultsData.push currentSearchResultsData
		  		  
		  		

		  		for series in data.seriesArray
		  			url = "/series/seriesId/#{series.id}/banners"
			  		((series, currentSearchResultsData) ->
			  			$http.get(url).success (data) ->
			  				#console.log data
			  				console.log series.name

			  				for banner in data
			  					console.log "windows.availheight", window.innerWidth
			  					if banner.type == "poster"
			  						currentSearchResultsData.currentSearchResults.push 
			  						 "name"             : series.name,
			  						 "id"               : series.id,
			  						 "bannerUrl"        : banner.url,
			  						 "altBannerUrl"     : series.banner
			  						 "currentBannerUrl" : if window.innerWidth<=800 then series.banner else banner.url
			  						break
			  				
			  				$scope.appData.searchRequestCompletionStatus = true

			  				return
			  			return
			  		)(series, currentSearchResultsData)
			  else
			  	console.log "no matching results found"
			  return 
		return


  

	$scope.appBehavior.viewSeries = (event) ->
		console.log "series clicked" 
		return
  
  $scope.appBehavior.restAppData = ->
    $scope.appData.allSearchResultsData = []
    $scope.appData.searchQuery = ""
    return;

	$scope.appBehavior.ifDataAvailable = (data) ->
		console.log data
		if data and data.length() > 0
			return true
		return false


  return 

]
searchApp.directive 'currentSearchResultsDirective', ->
	(scope,element,attrs) ->
		#if $('#all-search-results .current-search-results').length > 1
	
		window.setTimeout () ->
			$('#div-blur-layer').css "height", $('#div-search-section').css "height"
		,
		4000

		return



$(window).resize ->
	scope = angular.element('#div-search-section').scope()
	
	if window.innerWidth <= 800
		scope.$apply ->
			for allSearchResults in scope.appData.allSearchResultsData
				for searchResult in allSearchResults.currentSearchResults
					searchResult.currentBannerUrl = searchResult.altBannerUrl
			return
	else 
		scope.$apply ->
			for allSearchResults in scope.appData.allSearchResultsData
				for searchResult in allSearchResults.currentSearchResults
					searchResult.currentBannerUrl = searchResult.bannerUrl
			return

	return
