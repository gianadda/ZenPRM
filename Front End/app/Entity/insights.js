angular
    .module('App.EntityInsightsController', [])
    .controller('EntityInsightsController', [
        '$scope',
        '$rootScope',
        '$global',
        'growl',
        'identity',
        'MyProfileService',
        '$state',
        '$stateParams',
        function($scope, $rootScope, $global, growl, identity, MyProfileService, $state, $stateParams) {

            $scope.EntityIdent = $stateParams.ident;
            $scope.EntityLoaded = false;

            $scope.init = function() {

                if ($scope.EntityIdent) {

                    MyProfileService.getProfile($scope.EntityIdent).then(function(pl) {
                            $scope.EntityData = pl;
                            $scope.EntityDetails = $scope.EntityData.Entity[0];
                            $scope.EntityLoaded = true;
                            
                            $rootScope.PageTitle = $scope.EntityDetails.FullName + ' - Insights';
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });

                }
                else {
                    $state.go('site.notfound');
                }

            };

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
