'use strict'

angular
.module('App.EmailNotValid', [])
.controller('EmailNotValidController',
function ($scope, $log, $global, identity) {

    $log.debug("Loaded Controller: " + "EmailNotValidController");

    $scope.isLoggedIn = function() {
        return identity.isAuthenticated();
    }
});
