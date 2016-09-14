'use strict'

angular
.module('App.ForgotPasswordNotValid', [])
.controller('ForgotPasswordNotValid',
function ($scope, $log, $global, identity) {

    $log.debug("Loaded Controller: " + "ForgotPasswordNotValid");

    $scope.isLoggedIn = function() {
        return identity.isAuthenticated();
    }
});
