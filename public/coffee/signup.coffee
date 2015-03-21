$(window).ready ->
	$("#time-zone").val -(new Date).getTimezoneOffset()/60
	return

validateSignupFormData = ->
	return


signupapp = angular.module 'signupapp', []

signupapp.controller 'controller', [ '$scope','$http',($scope) ->
]