'use strict'

angular
    .module('App.DelegatesMenuController', ['ngTable'])
    .controller('DelegatesMenuController', [
    '$scope',
    '$rootScope',
    '$log',
    '$filter',
    '$timeout',
    '$http',
    '$global',
    'RESTService',
    'identity',
    'growl',
    '$window',
    'MyProfileService',
    '$sessionStorage',
    'delegationService',
    '$state',
function ($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, identity, growl, $window, MyProfileService, $sessionStorage, delegationService, $state) {

    // All functionality is defined in navigation.js

}]);