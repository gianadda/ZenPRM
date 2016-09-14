'use strict'

angular
.module('App.RegisterNotValid', [])
.controller('RegisterNotValidController',
function ($scope, $log, $global, identity) {

    $log.debug("Loaded Controller: " + "RegisterNotValidController");

    $scope.isLoggedIn = function() {
        return identity.isAuthenticated();
    }
});
