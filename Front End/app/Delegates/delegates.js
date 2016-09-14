'use strict'

angular
    .module('App.DelegatesController', ['ngTable'])
    .controller('DelegatesController', [
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
    'NgTableParams',
    '$modal',
function ($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, identity, growl, $window, MyProfileService, NgTableParams, $modal) {

            $scope.loading = true;
            $rootScope.EntityLoaded = false;

            $scope.LoadEntity = function () {

                identity.identity()
                    .then(function () {

                        $scope.MyIdent = identity.getUserIdent();
                        $scope.UserName = identity.getUserName();

                        MyProfileService.getProfile($scope.MyIdent).then(function (pl) {

                            $scope.EntityData = pl;
                            $scope.delegates = $filter('filter')(pl.EntityDelegate, {IsDelegateOf: true}, true);
                            $scope.loading = false;
                            },
                            function (errorPl) {
                                growl.error($global.GetRandomErrorMessage());

                            });

                    });

            };

            $scope.removeDelegate = function (connectionIdent) {

                var deleteEntityConnectionDelete;
                var postData = {
                    Ident: connectionIdent
                }
                deleteEntityConnectionDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYCONNECTION]), postData);

                return deleteEntityConnectionDelete.then(function (pl) {

                        growl.success('This delegate has been successfully removed.');

                        MyProfileService.clearProfileCache(); // need to indicate that changes have been made and need to refresh from server, so dump local cache
                        $scope.LoadEntity();
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    }
                );

            };

            $scope.showAddDelegateModal = function() {
               
                //(Setup) the modal and keep it in scope so we can call functions on it.
                $scope.AddDelegateModal = $modal.open({
                    animation: true,
                    templateUrl: 'AddDelegateModal.html',
                    scope: $scope,
                    size: 'lg'
                });

                //Create an "Ok" function to close the modal.
                $scope.AddDelegateModal.closeAndReload = function() {
                    
                    MyProfileService.clearProfileCache(); // need to indicate that changes have been made and need to refresh from server, so dump local cache
                    $scope.LoadEntity();
                    $scope.AddDelegateModal.close();
                };

            };

            $scope.IsCustomer = function() {
                return $global.isCustomer();
            }

            $scope.$watch("EntityData", function() {
                if ($scope.EntityData) {
                    //$scope.Person = $scope.CurrentEntity.Entity[0].Person;
                    $rootScope.EntityLoaded = true;

                    //$scope.DrawPageTitle();
                }
            });

            $scope.LoadEntity();

}]);