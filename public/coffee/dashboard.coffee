$('window').ready ->
	
	$('#options-bar .option').on 'click', (e) ->
		$("#options-bar .option").removeClass "active not-active"
		$(this).addClass "active"

		allOptionsBarOptions = $('#options-bar .option')

		allOptionsBarOptions.not($(this)).addClass('not-active')
		selectedOptionsBarOptionContentLink = $(this).data('link')
		console.log selectedOptionsBarOptionContentLink


		allOptionsBarOptionsContent = $('#options-bar-content .options-bar-option-content')
		allOptionsBarOptionsContent.removeClass "active"
		allOptionsBarOptionsContent.removeClass "not-active"

		selectedOptionsBarOptionContent = $("#options-bar-content .options-bar-option-content[data-link='"+selectedOptionsBarOptionContentLink+"']")
		selectedOptionsBarOptionContent.addClass "active"
		allOptionsBarOptionsContent.not(selectedOptionsBarOptionContent).addClass('not-active')
		console.log selectedOptionsBarOptionContent
		return

	return


# angular app for dashboard.html
dashboardApp = angular.module 'dashboard-app', []
dashboardApp.controller 'dashboard-controller', [ '$http', '$scope', ($http, $scope) ->
	console.log "setting controller" 
	$scope.appData = {}
	$scope.appData.subscribedTvShows = []
	$scope.appData.tvShowsToBeUnsubscribed = []
	$scope.appData.requestingSubscribedTvShows = true
	$scope.appData.downloadedSubscribedTvShows = false
	$scope.appData.days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	$scope.appData.ifTvShowsAiringToday = (airDay) ->
		for series in $scope.appData.subscribedTvShows
			if series.airsOnDayOfWeek == airDay
				return true
		return false
	return
]

# angular directive to handle user subscribed tv shows
dashboardApp.directive 'subscriptionsDirective', ['$timeout', '$http', ($timeout, $http) ->
	link: (scope, element, attrs) ->
		$(element).on 'click', (e) ->
			#start http request
			#already parses to string to json on receiving data
			$http.get('/subscriptions').success (result) ->
				console.log "dashboard result ", result
				
				scope.appData.requestingSubscribedTvShows = false
				scope.appData.subscribedTvShows = result.data

				progressBar = $("#request-progress-bar .progress-bar")
				progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
				progressBar.addClass "progress-bar-success"
			#end of http request

			return
		#end of click event handler
		element.trigger 'click'
		return
]

dashboardApp.directive 'subscribedTvShowDirective', ['$timeout', '$http', ($timeout, $http) ->
	link: (scope, element, attrs) ->
		$(element).on 'click', (e) ->
			$(this).toggleClass 'unsubscribe'
			$(this).find('.remove-series-indicator').toggleClass 'display'

			
			if $('.subscribed-tv-show.unsubscribe').length > 0
				$("#unsubscribe-tv-shows").addClass 'visible'
			else 
				$("#unsubscribe-tv-shows").removeClass 'visible'


			return
		#end of click event handler
		

		return
]

dashboardApp.directive 'unsubscribeSelectedTvShowsDirective', ['$timeout', ($timeout) ->
	link: (scope, elemement, attrs) ->
		#event listener handles unsubscribe tv shows button click
		elemement.on 'click', (e) ->
			console.log "unsubscribing the following tv shows"
			tvShowsToBeUnsubscribed = []
		
		
			$(".unsubscribe").each () ->
				series = $(this)
				tvShowsToBeUnsubscribed.push
					"id"							: series.data("seriesId")
					"name"						: series.data("seriesName")
					"airsOnDayOfWeek" : series.data("airsOnDayOfWeek")
				return

			$timeout ->
				scope.$apply ->
		    	scope.appData.tvShowsToBeUnsubscribed = tvShowsToBeUnsubscribed
		    	return
		    return

			$('#modal-tv-shows-to-be-unsubscribed').modal()
			return
		#end of event listener

		return
	#end of link function
]

dashboardApp.directive 'confirmUnsubscribeDirective', ['$timeout','$http', ($timeout, $http) ->
	link: (scope, elemement, attrs) ->
		#event listener handles unsubscribe tv shows button click
		elemement.on 'click', (e) ->
			$('#modal-tv-shows-to-be-unsubscribed').modal()

			progressBar = $("#request-progress-bar .progress-bar")
			progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
			progressBar.addClass "progress-bar-striped"

			tvShowsToBeUnsubscribed = []
			#tvShowsToBeUnsubscribed = scope.appData.tvShowsToBeUnsubscribed

			for series in scope.appData.tvShowsToBeUnsubscribed
				tvShowsToBeUnsubscribed.push {"id" : series.id}
			
			$http.post '/unsubscribe', {"tvShowsToBeUnsubscribed": tvShowsToBeUnsubscribed}
		  .success (data, status, headers, config) ->
		  	console.log "success unsubscribing", data
		  	progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
		  	progressBar.addClass "progress-bar-success"

		  	if !data.err
		  		$timeout ->
						scope.$apply ->
				    	#scope.appData.tvShowsToBeUnsubscribed

				    	for remove in $scope.appData.tvShowsToBeUnsubscribed
				    		$scope.appData.subscribedTvShows.splice remove
				    	return
				    return
				
		  	return  
		  .error (data, status, headers, config) ->
		  	return
			return
		#end of event listener

		return
	#end of link function
]

dashboardApp.filter 'filterTvShowsByAirDay', () ->
	return (seriesArray, airDay)->
		console.log "airDay", airDay
		seriesAiringOnDay = []
		for series in seriesArray
			if series.airsOnDayOfWeek == airDay
				seriesAiringOnDay.push series
		return seriesAiringOnDay
	return





###
$timeout ->
					scope.$apply ->
			    		scope.subscribedTvShows = subscribedTvShows
			    	return
			    return
###