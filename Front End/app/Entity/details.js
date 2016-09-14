angular
    .module('App.EntityDetailsController', [])
    .controller('EntityDetailsController', [
        '$scope',
        '$rootScope',
        '$global',
        'RESTService',
        'growl',
        'identity',
        'MyProfileService',
        '$state',
        '$stateParams',
        'LookupTablesService',
        'entityNetworkService',
        'entityHierarchyService',
        '$filter',
        function($scope, $rootScope, $global, RESTService, growl, identity, MyProfileService, $state, $stateParams, LookupTablesService, entityNetworkService, entityHierarchyService, $filter) {

            $scope.EntityIdent = $stateParams.ident;
            $scope.EntityLoaded = false;

            $scope.networkOrgs = [];
            $scope.hierarchyTags = {};

            $scope.init = function() {

                if ($scope.EntityIdent) {

                    MyProfileService.getProfile($scope.EntityIdent).then(function(pl) {
                            $scope.EntityData = pl;
                            $scope.EntityDetails = $scope.EntityData.Entity[0];
                            $scope.EntityLoaded = true;
                            
                            $rootScope.PageTitle = $scope.EntityDetails.FullName + ' - Details';

                            // Set up hierarchy
                            $scope.GetEntityHierarchy();
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });

                }
                else {
                    // Bad URL
                    $state.go('site.notfound');
                }

            };

            // ORGANIZATION HIERARCHY //

            $scope.GetEntityHierarchy = function() {

                if ($scope.IsCustomer()) {

                    $scope.HierarchyType = $filter('filter')(LookupTablesService.HierarchyType, { ToEntityIsPerson: $scope.EntityDetails.Person }, true);

                    entityHierarchyService.getEntityHierarchyAsTags($scope.EntityIdent, true).then(function(data) {
                        $scope.EntityHierarchy = data;

                        // $scope.WorksFor = $filter('filter')(data[1].tags);
                        // $scope.SubOrg = $filter('filter')(data[2].tags);
                        // $scope.WorksAt = $filter('filter')(data[3].tags);
                        // $scope.Member = $filter('filter')(data[4].tags);
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

            $scope.init();

        }
    ])
