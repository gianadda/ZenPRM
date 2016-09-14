'use strict'

angular
    .module('App.ProjectsController', [])
    .controller('ProjectsController', [
        '$scope',
        '$rootScope',
        '$log',
        '$filter',
        '$timeout',
        '$http',
        '$global',
        'RESTService',
        'growl',
        '$window',
        'identity',
        'LookupTablesService',
        'MyProfileService',
        'ChartJs',
        '$stateParams',
        '$state',
        'entityProjectService',
        function($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, growl, $window, identity, LookupTablesService, MyProfileService, ChartJs, $stateParams, $state, entityProjectService) {

            $scope.currentTab = 'open';
            $scope.loading = true;

            if ($stateParams.Tab) {
                $scope.currentProject = $stateParams.Tab;
            }
            $scope.labels = ["Response", "No Response"];

            $scope.init = function() {
                identity.identity()
                    .then(function() {

                        $scope.MyIdent = identity.getUserIdent();

                        MyProfileService.getProfile($scope.MyIdent).then(function(pl) {

                                $scope.CurrentEntity = pl;
                                $scope.LoadEntityProjects($scope.CurrentEntity.Entity[0].Ident);

                            },
                            function(errorPl) {
                                growl.error($global.GetRandomErrorMessage());
                                $scope.loading = false;
                            });
                    });
            }

            // Used to reinitialize screen after archiving or reactivating a project
            $scope.reinit = function() {
                $scope.init();
                $scope.searchFilter = undefined;
            }

            $scope.LoadEntityProjects = function(ident) {
                var getEntityProjectsByEntityIdent = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + '/GetEntityProjectsByEntityIdent', ident);

                getEntityProjectsByEntityIdent.then(function(pl) {
                        $scope.EntityProject = pl.data.EntityProject;
                        $scope.loading = false;

                        console.log($scope.EntityProject);
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.loading = false;
                    });
            }

            $scope.IsCustomer = function() {
                return $global.isCustomer();
            }

            $scope.addProject = function() {

                $state.go('site.ProjectEdit', { ident: 0 });

            };


            $scope.init();

        }
    ]);
