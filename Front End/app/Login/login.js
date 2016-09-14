'use strict'

angular
    .module('App.LoginController', [])
    .controller('LoginController', ['$scope',
        '$global',
        '$rootScope',
        '$log',
        '$state',
        'RESTService',
        'identity',
        'growl',
        function($scope, $global, $rootScope, $log, $state, RESTService, identity, growl) {

            $log.debug("Controller: " + "LoginController");

            $scope.username = '';
            $scope.password = '';
            $scope.invalid = false;

            //Delegates to identity.login()
            //Sets $global.settings.isLoggedIn to true on success
            //Returns an alert object { msg : "alert message", type : "danger" }
            $scope.login = function() {

                identity.login($scope.username, $scope.password).then(
                    //success
                    function(value) {

                        if (value && value.success) {

                        } else {
                            growl.error(value.msg);
                        }

                    }
                );
            }

        }
    ]);
