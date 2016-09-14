'use strict'

angular
.module('App.AccessDenied', [])
.controller('AccessDeniedController',
function ($scope, $log, $global, identity) {

    $log.debug("Loaded Controller: " + "AccessDeniedController");

    $scope.isLoggedIn = function() {
        return identity.isAuthenticated();
    }
});
