'use strict'

angular
    .module('App.RegisterController', [])
    .controller('RegisterController', [
    '$scope',
    '$rootScope',
    '$global',
    '$stateParams',
    'RESTService',
    'growl',
    'identity',
    'registrationService',
function ($scope, $rootScope, $global, $stateParams, RESTService, growl, identity, registrationService) {

            $scope.init = function(){

                // variable passed down to directive to change how it works based on modal/embedded view
                $scope.atRegistration = true;

                //validate the GUID to make sure it is still valid
                registrationService.checkRegistrationID($stateParams.id);

            };

            $scope.register = function () {

                registrationService.register($scope.username, $scope.newPassword, $scope.confirmNewPassword);

            }; // register

            $scope.init();

}]);