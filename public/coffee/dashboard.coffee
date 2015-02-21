$('window').ready ->
	
	$('#options-bar .option').on 'click', (e) ->
		$("#options-bar .option").removeClass "active not-active"
		$(this).addClass "active"
		selectedOptionsBarOptionContentLink = $(this).data('link')
		console.log selectedOptionsBarOptionContentLink


		allOptionsBarOptionsContent = $('#options-bar-content .options-bar-option-content')
		allOptionsBarOptionsContent.removeClass "active not-active"

		selectedOptionsBarOptionContent = $("#options-bar-content .options-bar-option-content[data-link='"+selectedOptionsBarOptionContentLink+"']")
		selectedOptionsBarOptionContent.addClass "active"
		allOptionsBarOptionsContent.not(selectedOptionsBarOptionContent).addClass('not-active')
		console.log selectedOptionsBarOptionContent
		return
	
	return


# angular app for dashboard.html
dashboardApp = angular.module 'dashboard-app', []
dashboardApp.controller 'controller', [ '$http', '$scope', ($http, $scope) ->
	console.log "setting controller"
	$scope.appData = {}
	$scope.appData.subscribedTvShows = []
	$scope.appData.requestingSubscribedTvShows = true
	$scope.appData.downloadedSubscribedTvShows = false
	return
]

# angular directive to handle user subscribed tv shows
dashboardApp.directive 'subscriptionsDirective', ['$timeout', '$http', ($timeout, $http) ->
	link: (scope, elemement, attrs) ->
		console.log "subscriptioons option created"
		$(elemement).on 'click', (e) ->
			#start http request
			#already parses to string to json on receiving data
			$http.get('/subscriptions').success (result) ->
				console.log "dashboard result ", result
				
				scope.appData.requestingSubscribedTvShows = false
				scope.appData.subscribedTvShows = result.data
			#end of http request

			return
		#end of click event handler

		return
]



###
$timeout ->
					scope.$apply ->
			    		scope.subscribedTvShows = subscribedTvShows
			    	return
			    return
###