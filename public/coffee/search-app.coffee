
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
	$scope.appData.host = "http://tvserieswebapp.herokuapp.com" 
	$scope.appData.progressIndicatorStatus = false

	$scope.appData.user =
		"first-name" : ""
		"email"      : ""
		"username"   : ""
		"signed-in"  : ""

	###
	url = "#{$scope.appData.host}/signin-status"
	$http.get(url).success (data) ->
		console.log "data is"
		console.log data
		$scope.appData.user =
			"first-name"    : data["first-name"]
			"email"         : data["email"]
			"username"      : data["username"]
			"signin-status" : data["signin-status"]
  ###



  #$scope.appData.requestStatus = true
	
  

	$scope.appBehavior.onKeyUp = (event) ->
		if event.keyCode == 13 
		  console.log $scope.appData.searchQuery
		  $scope.appData.progressIndicatorStatus=true
		  searchQuery = encodeURIComponent $scope.appData.searchQuery
		  url = "#{$scope.appData.host}/series/seriesName/#{searchQuery}"
		  $http.get(url).success (data) ->
		  	$scope.appData.progressIndicatorStatus = false
		  	if data.seriesArray
		  		currentSearchResultsData =
		  			#"currentSearchQuery"   : ($scope.appData.searchQuery),
		  		  "currentSearchResults" : []

		  		$scope.appData.allSearchResultsData.push currentSearchResultsData
		  		  
		  		
		  		for series in data.seriesArray
		  			url = "#{$scope.appData.host}/series/seriesId/#{series.id}/banners"
			  		((series, currentSearchResultsData) ->
			  			$http.get(url).success (data) ->
			  				#console.log data
			  				console.log series.name

			  				for banner in data
			  					if banner.type == "poster"
			  						currentSearchResultsData.currentSearchResults.push 
			  						 "name"      : series.name,
			  						 "id"        : series.id,
			  						 "bannerUrl" : banner.url
			  						break
			  				return
			  			return
			  		)(series, currentSearchResultsData)
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
	
		$('#div-blur-layer').css "height", $('#div-search-section').css "height"

		return

###
searchApp.directive 'signInStatusDirective', ->
	scope: false,
	transclude: false,
	link: (scope,element,attrs) ->
		#if $('#all-search-results .current-search-results').length > 1
	  
		$(element).on 'click', (event) ->
			
			console.log scope.appData
			if scope.appData.user["signin-status"]
				event.preventDefault()
				$("#signin-to-app").addClass 'dropdown'
				$("#signin-to-app .dropdown-toggle").attr("data-toggle","dropdown")
			
			return
				

		return

###

