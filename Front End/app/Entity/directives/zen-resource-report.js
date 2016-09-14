angular.module('App.zenResourceReport', ['ui.bootstrap'])
    .directive('zenResourceReport', function() {
        return {
            restrict: 'E',
            scope: {
                reportHtml: '=',
                reportMeasureData: '=',
                profile: '='
            },
            templateUrl: 'Entity/directives/zen-resource-report.html',
            controller: function($scope, $sce, $compile, $filter) {

                angular.element(document.getElementById('reportBody')).empty()

                var chart = angular.element(document.createElement('chart'));
                chart.html($scope.reportHtml);
                var el = $compile(chart)($scope);

                //where do you want to place the new element?
                angular.element(document.getElementById('reportBody')).append(chart);

                $scope.getMeasureData = function(MeasureIdent) {
                    var data = {}

                    //console.log($scope.reportMeasureData);

                    if ( $filter('filter')($scope.reportMeasureData, { MeasureIdent: MeasureIdent }, true).length > 0 ) {
                        data = $filter('filter')($scope.reportMeasureData, { MeasureIdent: MeasureIdent }, true)[0].MeasureData;
                    }
                    else {
                        data = 'N/A';
                    }

                    return data;

                };

            }

        };

    });
