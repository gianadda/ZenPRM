'use strict'

angular
    .module('App.ProjectEditController', ['angular-clipboard'])
    .controller('ProjectEditController', [
    '$scope',
    '$rootScope',
    '$log',
    '$filter',
    '$timeout',
    '$interval',
    '$http',
    '$global',
    'RESTService',
    'growl',
    '$window',
    'identity',
    '$sce',
    '$stateParams',
    'MyProfileService',
    '$state',
    'entityProjectService',
    'clipboard',
function ($scope, $rootScope, $log, $filter, $timeout, $interval, $http, $global, RESTService, growl, $window, identity, $sce, $stateParams, MyProfileService, $state, entityProjectService, clipboard) {

            //setup navigation
            $rootScope.currentProjectIdent = $stateParams.ident;
            $rootScope.currentlySelectedProjectTab = 'Details';
            $scope.EntityProject = {};
            $scope.EntityProject.addModeOptions = 'Both';
            $scope.addMode = false;
            $scope.projectManagers = [];

            $scope.CustomerName = identity.getUserName();

            // For share link
            $scope.CopySupported = false;
            $scope.ShowCopySuccess = false;
            $scope.ShowCopyError = false;


            $scope.init = function () {
                
                var ident = identity.getUserIdent();
                
                 MyProfileService.getProfile(ident).then(function (pl) {
                    $scope.projectManagers = pl.EntityDelegate;
                    $scope.entityProjects = pl.EntityProject;
                },
                function (errorPl) {
                    // the following line rejects the promise 

                });
                
                if ($rootScope.currentProjectIdent && $rootScope.currentProjectIdent > 0){

                    // were in edit mode, so load the existing project data
                    $scope.loadExistingProject();

                } else {
                    
                    // were in add mode
                    $scope.addMode = true;
                    $scope.EntityProject.ProjectType = 'Admin'; // default to Admin Only
                    
                };

            };
    
            $scope.TrustEmailHTML = function (email) {

                return $sce.trustAsHtml(email);

            }
          
            $scope.ReactivateProject = function(){

                entityProjectService.ReactivateProject($rootScope.currentProjectIdent).then(function(pl){

                    $scope.EntityProject.Archived = false;
                    growl.success('This project has been successfully reactivated!');

                }, function (errorPl){
                    growl.error($global.GetRandomErrorMessage());
                });


            };

            $scope.loadExistingProject = function(){

                var getEntityProjectRequirements = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTDETAILS]), $stateParams.ident);

                getEntityProjectRequirements.then(function (pl) {

                    $scope.EntityProject = pl.data.EntityProject[0];

                    $rootScope.PageTitle = $scope.EntityProject.Name1 + ' - Settings';

                    $scope.convertProjectType(true); // convert project flags to ProjectType

                    // Check if "copy to clipboard" is supported
                    $scope.CheckCopySupport();

                });

            }; //loadExistingProject
    
            $scope.saveProject = function(){

                $scope.convertProjectType(false); // convert project flags to ProjectType
                
                if (!$scope.addMode) {
                    
                    var putProject = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), $rootScope.currentProjectIdent, $scope.EntityProject);

                    putProject.then(function (pl) {

                            growl.success($global.GetRandomSuccessMessage());
                            //rebind after save
                            $scope.loadExistingProject();

                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                    
                } else {

                    // get the copy project state and pass to the appropriate variables
                    if ($scope.EntityProject.addModeOptions == 'Both' || $scope.EntityProject.addModeOptions == 'Participants'){

                        $scope.EntityProject.IncludeParticipants = true;

                    };


                    if ($scope.EntityProject.addModeOptions == 'Both' || $scope.EntityProject.addModeOptions == 'Questions'){

                        $scope.EntityProject.IncludeQuestions = true;

                    };

                    
                    var postProject = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), $scope.EntityProject);

                    postProject.then(function (pl) {

                            MyProfileService.clearProfileCache(); // need to indicate that changes have been made and need to refresh from server, so dump local cache

                            $rootScope.currentProjectIdent = pl.data;
                            $scope.addMode = false;
                        
                            growl.success("Great work! Your new project has been added. Don't forget to add questions and participants to this project. If it is not a private project, you will be able to send an email notification to resources from the Participant screen.", {ttl: 10000});
                        
                            // since were done adding, reload page in edit mode
                            $state.go('site.ProjectEdit', {ident: $rootScope.currentProjectIdent });
                        
                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                    
                };
                
            };

            $scope.archiveProject = function(){
                
                var postEntityProject;
                var postData = {
                    EntityProjectIdent: $rootScope.currentProjectIdent
                }
                postEntityProject = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTARCHIVE]), postData);

                return postEntityProject.then(function (pl) {
                        MyProfileService.clearProfileCache(); // need to indicate that changes have been made and need to refresh from server, so dump local cache
                        growl.success($scope.EntityProject.Name1 + " has been successfully archived.");    
                        $state.go('site.Projects');
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    }
                );
                
            };
    
            $scope.deleteProject = function(){
                
                var delEntityProject = RESTService.delete(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), $rootScope.currentProjectIdent);

                return delEntityProject.then(function (pl) {

                        MyProfileService.clearProfileCache(); // need to indicate that changes have been made and need to refresh from server, so dump local cache
                        growl.success($scope.EntityProject.Name1 + " has been successfully deleted.");    
                        $state.go('site.Projects');
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    }
                );
                
            };

            $scope.convertProjectType = function(reverse){

                if (reverse){

                    if ($scope.EntityProject.PrivateProject){

                        $scope.EntityProject.ProjectType = 'Admin';

                    } else if ($scope.EntityProject.AllowOpenRegistration){

                        $scope.EntityProject.ProjectType = 'Open';

                    } else {

                        $scope.EntityProject.ProjectType = 'AdminParticipants';

                    };


                } else {

                    if ($scope.EntityProject.ProjectType == 'Admin'){

                        $scope.EntityProject.PrivateProject = true;
                        $scope.EntityProject.AllowOpenRegistration = false;

                    } else if ($scope.EntityProject.ProjectType == 'Open'){

                        $scope.EntityProject.PrivateProject = false;
                        $scope.EntityProject.AllowOpenRegistration = true;

                    } else {

                        $scope.EntityProject.PrivateProject = false;
                        $scope.EntityProject.AllowOpenRegistration = false;

                    }

                };
                
            }; //convertProjectType


            $scope.CheckCopySupport = function () {
                if ( $scope.EntityProject.AllowOpenRegistration && $scope.EntityProject.ProjectShareLink ) {
                    if ( clipboard.supported ) {
                        $scope.CopySupported = true;
                        //console.log(clipboard);
                    }
                }
            }

            $scope.CopySuccess = function () {
                $scope.ShowCopySuccess = true;
                $scope.ShowCopyError = false;

                $timeout(function() {
                    $scope.ShowCopySuccess = false;
                }, 2000);
            }

            $scope.CopyError = function () {
                $scope.ShowCopyError = true;
                $scope.ShowCopySuccess = false;
            }

            $scope.init();

    }]);