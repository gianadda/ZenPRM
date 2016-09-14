'use strict'

angular
.module('App.OAuthRedirect', [])
.controller('OAuthRedirectController',['$scope',
        '$log',
        '$stateParams',
        'identity',
		function ($scope, $log, $stateParams, identity) {

	    $scope.OAuthLogin = function() {

		    $log.debug("Controller: " + "OAuthRedirectController");

		    $scope.projectGUID = $stateParams.id;

		        identity.loginExternal($scope.projectGUID).then(
		            //success
		            function(value) {

		            }
		        );
	    }; // $scope.OAuthLogin 


	    $scope.OAuthLogin();


}]);
