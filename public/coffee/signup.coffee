$(window).ready ->
	$("#time-zone").val -(new Date).getTimezoneOffset()/60
	return

validateSignupFormData = ->
	return


signupapp = angular.module 'signupapp', ['ui.utils']

signupapp.controller 'signupAppController', [ '$scope','$http',($scope) ->
] 


signupapp.directive 'signupFormDirective', ['$http', '$timeout', ($http, $timeout) ->
  link: (scope, element, attrs) ->
    scope.signupForm.username.available = true
    scope.signupForm.username.checkAvailabilityReminder = false
    
    $("#check-username-availability").on 'click', (e) ->

      $("#check-username-availability .progress").toggleClass "hidden"
      $("#check-username-availability .search").toggleClass "hidden"
      console.log "username entered", scope.formData.username
      username = scope.formData.username
      
      $http.post '/checkUsernameAvailability', {"username": username}
      .success (result, status, headers, config) ->
        console.log "client data",  result
        if !result.err 
          scope.signupForm.username.checkUsernameAvailabilityCount++;
          if result.data == 1
            console.log "username available"
            scope.signupForm.username.available = true
          else 
            console.log "username not available"
            scope.signupForm.username.available = false
          
          $("#check-username-availability .progress").toggleClass "hidden"
          $("#check-username-availability .search").toggleClass "hidden"
          scope.signupForm.username.checkAvailabilityReminder = false
        return
      .error (result, status, headers, config) ->
        return

    scope.signupForm.username.updateUsernameAvailabilitystatus = () ->
      scope.signupForm.username.checkAvailabilityReminder = true

    return
]