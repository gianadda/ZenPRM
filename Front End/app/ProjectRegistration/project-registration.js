'use strict'

angular
    .module('App.ProjectRegistration', [])
    .controller('ProjectRegistrationController', ['$scope',
        '$state',
        '$stateParams',
        'identity',
        'growl',
        'projectRegistrationService',
        function($scope, $state, $stateParams, identity, growl, projectRegistrationService) {

            $scope.login = function() {

                identity.login($scope.username, $scope.password, $scope.projectGUID).then(
                    //success
                    function(value) {

                        if (value.success) {

                        } else {
                            growl.error(value.msg);
                        }

                    }
                );
            }; // login

            $scope.register = function() {

                projectRegistrationService.registerForOpenProject($scope.projectGUID, $scope.registration).then(function(data) {
                        
                        // validate the link and if its not valid take the user to an error landing page
                        if (data){
                            $state.go('registration-pending');
                        };

                    },
                    function(errorPl) {
                        growl.error('Registration could not be completed at this time. Please ensure that all required fields have been submitted.');
                    });

            }; // login

            $scope.init = function(){

                $scope.username = '';
                $scope.password = '';
                $scope.invalid = false;
                $scope.projectGUID = $stateParams.id;
                $scope.project = {};
                $scope.registration = {};

                projectRegistrationService.verifyOpenProjectLink($scope.projectGUID).then(function(data) {
                        
                        // validate the link and if its not valid take the user to an error landing page
                        if (data && data.Ident){
                            $scope.project = data;
                        } else {
                            $state.go('project-registration-notvalid');
                        };

                    },
                    function(errorPl) {
                        $state.go('project-registration-notvalid');

                    });


            }; //init

            $scope.init();

        }
    ]);
