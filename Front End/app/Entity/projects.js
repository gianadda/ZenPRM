angular
    .module('App.EntityProjectsController', [])
    .controller('EntityProjectsController', [
        '$scope',
        '$rootScope',
        '$log',
        '$filter',
        '$global',
        'RESTService',
        'growl',
        'identity',
        'MyProfileService',
        '$state',
        '$stateParams',
        function($scope, $rootScope, $log, $filter, $global, RESTService, $window, identity, MyProfileService, $state, $stateParams) {

            $scope.EntityIdent = $stateParams.ident;
            $scope.currentProject = 'openprojects';
            $scope.loading = true;
            $scope.EntityLoaded = false;

            if ($scope.EntityIdent) {

                MyProfileService.getProfile($scope.EntityIdent).then(function(pl) {
                        $scope.EntityData = pl;
                        $scope.EntityDetails = $scope.EntityData.Entity[0];
                        $scope.EntityLoaded = true;

                        $scope.LoadEntityProjects($scope.EntityDetails.Ident);
                        
                        $rootScope.PageTitle = $scope.EntityDetails.FullName + ' - Projects';
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.EntityLoaded = true;
                        $scope.loading = false;
                    });
            }
            else {
                $state.go('site.notfound');
            }


            $scope.LoadEntityProjects = function(ident) {
                var getEntityProjectsByEntityIdent = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + '/GetEntityProjectsByEntityIdent', ident);

                getEntityProjectsByEntityIdent.then(function(pl) {
                        $scope.EntityProject = pl.data.EntityProject;

                        angular.forEach($scope.EntityProject, function(value, key) {
                            value.RemainingQuestions = value.TotalEntityProjectEntityEntityProjectRequirement - value.TotalEntityProjectEntityEntityProjectAnswers;
                        });

                        if ($scope.IsCustomer()) {
                            $scope.OpenProjects = $filter('filter')($scope.EntityProject, {Archived: false});
                            $scope.ArchivedProjects = $filter('filter')($scope.EntityProject, {Archived: true});
                        }
                        else {
                            $scope.OpenProjects = $filter('filter')($scope.EntityProject, {Archived: false, PrivateProject: false});
                            $scope.ArchivedProjects = $filter('filter')($scope.EntityProject, {Archived: true, PrivateProject: false});
                        }

                        $scope.loading = false;

                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.loading = false;
                    });
            }

            $scope.showTab = function(proj) {
                $scope.currentProject = proj;
            }

            $scope.drawComplete = function(percent) {
                return parseInt(percent) + '%';
            }

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

        }
    ]);
