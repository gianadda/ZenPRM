'use strict'

angular
.module('App.NotFound', [])
.controller('NotFoundController',
function ($scope, $log, $global, identity) {

    $log.debug("Loaded Controller: " + "NotFoundController");

    $scope.goBack = function(){

    	window.history.go(-2); // need to go back 2 pages, because going back 1 page would be to the page that caused the 404
    	
    };

    $scope.isLoggedIn = function() {
        return identity.isAuthenticated();
    }
});
