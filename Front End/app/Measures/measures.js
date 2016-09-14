angular
    .module('App.MeasuresController', [])
    .controller('MeasuresController', [
    '$scope',
    '$rootScope',
    'growl',
    '$location',
    '$anchorScroll',
    '$stateParams',
    '$filter',
    'entityProjectMeasuresService',
    '$timeout',
function ($scope, $rootScope, growl, $location, $anchorScroll, $stateParams, $filter, entityProjectMeasuresService, $timeout) {

            // Call functions on load
            $scope.init = function () {

                $scope.loading = true;
                $scope.MeasuresData = [];

                // Load tab
                $scope.MeasureIdent = $stateParams.ident;
                $scope.CurrentTab = $stateParams.tab;

                $scope.GetMeasuresData();

            };

            // Fetch measure data from end point
            $scope.GetMeasuresData = function () {

                 entityProjectMeasuresService.getDialEntityHierarchy($scope.MeasureIdent).then(function (data) {
                        $scope.MeasuresData = data;
                        $scope.MeasureName = $scope.MeasuresData.EntityMeasure;
                        $rootScope.PageTitle = $scope.MeasureName + ' - Measure';
                        $scope.loading = false;
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.MeasuresData = [];
                        $scope.loading = false;
                    });

            };

            $scope.init();

}]);