angular
    .module('App.EntityHierarchyController', [])
    .controller('EntityHierarchyController', [
    '$scope',
    '$rootScope',
    '$log',
    '$filter',
    '$global',
    'RESTService',
    'growl',
    'NgTableParams',
    'entityHierarchyService',
    'MyProfileService',
    '$state',
    '$stateParams',
    'identity',
function ($scope, $rootScope, $log, $filter, $global, RESTService, growl, NgTableParams, entityHierarchyService, MyProfileService, $state, $stateParams, identity) {

            $scope.EntityLoaded = false;
            $scope.loading = true;

            $scope.EntityIdent = $stateParams.FromEntityIdent;

            $scope.$watch("ReloadGrid", function () {
                $scope.tableParams.reload();
                $scope.ReloadGrid = false;
            });

            var orderedData;
            var fullOrderedData;

            $scope.tableParams = new NgTableParams({
                page: 1, // show first page
                count: 10, // count per page
                sorting: {
                    DisplayName: 'asc'
                }
            }, {
                counts: [5, 10, 25, 50, 100],
                //total: $scope.EntityProjectEntity.length, // length of data
                getData: function (params) {

                    orderedData = $scope.EntityHierarchy;

                    //First do the sorting
                    orderedData = params.sorting() ? $filter('orderBy')(orderedData, params.orderBy()) : orderedData;

                    //Then the filtering
                    orderedData = params.filter() ? $filter('filter')(orderedData, params.filter()) : orderedData;

                    fullOrderedData = orderedData;

                    params.settings().total = orderedData.length;

                    //Then the paging
                    orderedData = orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count());

                    return orderedData;
                }

            });

            $scope.init = function () {

                if ($scope.EntityIdent) {

                    // Get basic entity data
                    MyProfileService.getProfile($scope.EntityIdent).then(function(pl) {
                            $scope.EntityData = pl;
                            $scope.EntityDetails = $scope.EntityData.Entity[0];
                            $scope.EntityLoaded = true;
                            
                            $rootScope.PageTitle = $scope.EntityDetails.FullName + ' - Org Structure';

                            $scope.LoadHierarchy();
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });

                }
                else {
                    $state.go('site.notfound');
                }

            };

            $scope.LoadHierarchy = function() {
                // Get hierarchy data
                $scope.ReloadGrid = false;
                $scope.EntityHierarchy = [];

                entityHierarchyService.getEntityHierarchyAsTags($scope.EntityIdent).then(function (pl) {

                    $scope.EntityHierarchy = pl.Hierarchy;
                    $scope.ReloadGrid = true;
                    $scope.loading = false;

                    
                });
            }

            $scope.RemoveEntityFromHierarchy = function(ident){

                entityHierarchyService.deleteEntityHierarchy(ident).then(function (pl) {
                    
                    $scope.init();
                    
                });

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

            $scope.init();

}]);