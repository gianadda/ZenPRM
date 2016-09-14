'use strict'

angular
    .module('App.DashboardController', ['chart.js'])
    .controller('DashboardController', [
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
    '$interval',
    '$modal',
    '$state',
    '$stateParams',
    'entityProjectMeasuresService',
function ($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, identity, growl, $window, MyProfileService, $interval, $modal, $state, $stateParams, entityProjectMeasuresService) {

            // Call functions on load
            $scope.init = function () {

                $scope.LoadingMeasures = true;
                $scope.LoadingProjects = true;
                $scope.MeasuresData = [];
                $scope.ProjectQuestions1 = [];
                $scope.ProjectQuestions2 = [];
                $scope.MeasuresToggled = false;

                $scope.GetMeasuresData();
                $scope.LoadEntityProjects(identity.getUserIdent());

            };

            // Fetch measure data from end point
            $scope.GetMeasuresData = function () {

                $scope.LoadingMeasures = true;

                var ident = '1';
                if ($scope.MeasuresToggled) {
                    ident = '0';
                }

                 entityProjectMeasuresService.getDashboardDials(ident).then(function (data) {
                        $scope.MeasuresData = data;
                        $scope.LoadingMeasures = false;
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.MeasuresData = [];
                        $scope.LoadingMeasures = false;
                    });

            }; //GetMeasuresData

            $scope.AddNewMeasure = function() {
                $scope.$broadcast('openNewDialModel',{});
            };

            // Load Projects
            // Used to load projects on dashboard and project list in new dial modal
            $scope.LoadEntityProjects = function (ident) {
                var getEntityProjectsByEntityIdent = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + '/GetEntityProjectsByEntityIdent', ident);

                getEntityProjectsByEntityIdent.then(function (pl) {
                        $scope.EntityProject = pl.data.EntityProject;
                        $scope.LoadingProjects = false;
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.LoadingProjects = false;
                    });
            }

            // Draw percent complete
            $scope.drawComplete = function (percent) {
                return parseInt(percent) + '%';
            }

            $scope.MeasureClick = function (measure) {
                $state.go('site.measures', {ident: measure.Ident, tab: 'dials'});
            }

            $scope.ToggleMeasures = function () {
                $scope.MeasuresToggled = !$scope.MeasuresToggled;
                $scope.GetMeasuresData();
            }

            $scope.init();

}]);