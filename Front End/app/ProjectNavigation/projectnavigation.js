'use strict'

angular
    .module('App.ProjectNavigationController', [])
    .controller('ProjectNavigationController', [
    '$scope',
    '$log',
    '$global',
    '$state',
    'identity',
    'growl',
    'RESTService',
    '$rootScope',
    '$stateParams',
function ($scope, $log, $global, $state, identity, growl, RESTService, $rootScope, $stateParams) {

            $scope.toggleMenu = false;
            
            $rootScope.$watch("CurrentProfileEntityIdent", function () {

                $scope.currentProjectIdent = $rootScope.currentProjectIdent;
                
            });

}]);