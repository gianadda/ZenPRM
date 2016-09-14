angular
    .module('App.RepositoryController', [])
    .controller('RepositoryController', [
    '$scope',
    '$rootScope',
    '$timeout',
    '$global',
    'growl',
    '$stateParams',
    '$state',
    'MyProfileService',
    'identity',
    'RESTService',
function ($scope, $rootScope, $timeout, $global, growl, $stateParams, $state, MyProfileService, identity, RESTService) {

            $scope.isAddingFileToProject = false;
            $scope.projectIdent = $stateParams.projectIdent; 
            $scope.EntityIdent = $stateParams.entityIdent;
            $scope.FilesLoaded = false
            $scope.EntityLoaded = false;

            $scope.init = function () {

                if ($scope.EntityIdent) {

                    MyProfileService.getProfile($scope.EntityIdent).then(function (pl) {
                            $scope.EntityData = pl;
                            $scope.EntityDetails = $scope.EntityData.Entity[0];
                            $scope.EntityLoaded = true;

                            $rootScope.PageTitle = $scope.EntityDetails.FullName + ' - Files';
                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                            $scope.EntityLoaded = true;
                        });

                }
                else {
                    $state.go('site.notfound');
                }

                $scope.getFiles();

                $scope.isAddingFileToProject = $stateParams.requirementIdent ? true : false;

            };

            $scope.getFiles = function () {

                if ($scope.EntityIdent) {

                    var filesGET = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY,$stateParams.entityIdent,$global.RESTControllerNames.FILES]));

                } else {

                    var ident = identity.getUserIdent();

                    var filesGET = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY,ident,$global.RESTControllerNames.FILES]));
                };

                filesGET.then(function (pl) {
                        $scope.repoFiles = pl.data;
                        $scope.FilesLoaded = true;

                        angular.forEach($scope.repoFiles, function(value,key){

                            value.downloadLink = $scope.getFileLink(value);

                        });

                    },
                    function (errorPl) {
                        $scope.repoFiles = null;
                        $scope.FilesLoaded = true;
                    });

            };

            $scope.getFileLink = function(file){

                // if the state param is set, we're getting the file for the participant in the customers project
                if ($stateParams.entityIdent){

                    var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITY,$stateParams.entityIdent,$global.RESTControllerNames.FILES,file.AnswerIdent]);

                } else {

                    var ident = identity.getUserIdent();

                    var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITY,ident,$global.RESTControllerNames.FILES,file.AnswerIdent]);

                };

                return URI;

            };

            $scope.addFileToProject = function (answerIdent) {

                var entityIdent = $scope.EntityIdent ? $scope.EntityIdent : 0;

                var postData = {
                    requirementIdent: $stateParams.requirementIdent,
                    answerIdent: answerIdent,
                    entityIdent: entityIdent
                };

                if ($scope.EntityIdent) {

                    var addFromRepoPOST = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY,$scope.EntityIdent,$global.RESTControllerNames.FILES]), postData);

                } else {

                    var ident = identity.getUserIdent();

                    var addFromRepoPOST = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY,ident,$global.RESTControllerNames.FILES]), postData);

                };

                addFromRepoPOST.then(function (pl) {

                        // Make sure the project screen is put back to normal prior to navigating back to the page
                        $rootScope.AnswerMode = false;

                        growl.success('The file has been successfully added to the project. It will now appear under the submitted requirements.');

                        $scope.returnToProject();
                        

                    },
                    function (errorPl) {
                        growl.error('We were not able to add this file to the project at this time.');
                    });

            }; //addFileToProject

            $scope.deleteFile = function (fileRepositoryIdent) {

                var ident = identity.getUserIdent();
  
                var deleteEntityFileRepository = RESTService.delete(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY,ident,$global.RESTControllerNames.FILES]), fileRepositoryIdent);

                deleteEntityFileRepository.then(function (pl) {
                    
                    growl.success('The file has been successfully removed from your repository.');

                    $scope.getFiles();

                },
                function (errorPl) {
                    growl.error($global.GetRandomErrorMessage());
                });
  
            }; //deleteFile

            $scope.returnToProject = function() {

                if ($scope.projectIdent && $scope.EntityIdent) {

                    $state.go('site.Project', {
                        ident: $scope.projectIdent,
                        entityIdent: $scope.EntityIdent
                    });

                } else {
                    $state.go('site.Project', {
                        ident: pl.data[0].ProjectIdent
                    });
                };

            };

            // HELPER FUNCTIONS //

            $scope.IsCustomer = function() {
                return $global.isCustomer();
            }

            $scope.IsMyProfile = function(ident) {
                var bolValid = false;
                if (identity.getUserIdent() == ident) {
                    bolValid = true;
                }
                return bolValid;
            }

            $scope.Loaded = function() {
                if ($scope.EntityLoaded && $scope.FilesLoaded) {
                    return true;
                }
            }

            $scope.init();

}]);