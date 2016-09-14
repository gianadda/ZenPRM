'use strict'

angular
.module('App.EmailValid', [])
.controller('EmailValidController',
function ($scope, $log, $global, identity) {

    $log.debug("Loaded Controller: " + "EmailValidController");

    $scope.isLoggedIn = function() {
        return identity.isAuthenticated();
    }
});
