$('window').ready ->
	
	$('#sidebar .option').on 'click', (e) ->
		$("#sidebar .option").removeClass "active not-active"
		$(this).addClass "active"
		selectedSidebarOptionContentLink = $(this).data('link')
		console.log selectedSidebarOptionContentLink


		allSidebarOptionsContent = $('#sidebar-content .sidebar-option-content')
		allSidebarOptionsContent.removeClass "active not-active"

		selectedSidebarOptionContent = $("#sidebar-content .sidebar-option-content[data-link='"+selectedSidebarOptionContentLink+"']")
		selectedSidebarOptionContent.addClass "active"
		allSidebarOptionsContent.not(selectedSidebarOptionContent).addClass('not-active')
		console.log selectedSidebarOptionContent
		return
	
	return


# angular app for dashboard.html
dashboardApp = angular.module 'dashboard-app', []
dashboardApp.controller 'controller', [ '$http', '$scope', ($http, $scope) ->
	console.log "setting controller"
	this.appData = {}
	this.appData.subscribedTvShows = []
	return
]

# angular directive to handle user subscribed tv shows
dashboardApp.directive 'subscriptionsDirective', ['$timeout', '$http', ($timeout, $http) ->
	link: (scope, elemement, attrs) ->
		console.log "subscriptioons option created"
		$(elemement).on 'click', (e) ->
			#start http request
			$http.get('/subscriptions').success (subscribedTvShows) ->
				console.log subscribedTvShows
				#adding subscribed tv shows to the scope after 1 cycle
				$timeout ->
					scope.$apply ->
			    		scope.subscribedTvShows = subscribedTvShows
			    	return
			    return
				return
			#end of http request

			return
		#end of click event handler

		return
]