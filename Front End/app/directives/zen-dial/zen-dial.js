angular.module('App.zenDial', ['chart.js'])
.directive('zenDial', function() {
  return {
    restrict: 'AE',
    scope: {
    	measure: '=measure',
    	allowEdit: '@',
        dialClick: '=',
        dialClass: '@',
        reloadDials: '='
    },
    templateUrl: 'directives/zen-dial/zen-dial.html',
    controller: function (entityProjectMeasuresService, $filter, $interval, $modal, $rootScope, $scope) {

        // Variable Glossary
        // FullValue = this is the full calculated value and is displayed in the popup
        // Percentage = capped at 100%, and used for the Percentage measures to animate the dials
        // DisplayValue = The value that is displayed in the center of the dial
        // PrettyValue = The cleaned up/rounded version of the calculation value


        $scope.initDial = function(){

            // When measures are embedded within reports, they will be drawn even
            // if the Resource is not on the Project. In those cases, 'N/A' is 
            // passed in as the measure data.
            if ($scope.measure != 'N/A') {

                // if its already a percentage, then use the ranges to determine the dial % complete
                if ($scope.measure.IsPercentage){

                    if ($scope.measure.Question2Value > 0){

                        $scope.measure.FullValue = ($scope.measure.Question1Value / $scope.measure.Question2Value) * 100;
                        $scope.measure.Percentage = Math.round($scope.measure.FullValue);
                        // This accounts for values over 100% and is used in character counting
                        $scope.measure.PrettyValue = entityProjectMeasuresService.prettyNumber($scope.measure.Percentage);

                    } else {

                        $scope.measure.FullValue = 'N/A';
                        $scope.measure.DisplayValue = 'Not Answered';
                        $scope.measure.PrettyValue = 'Not Answered';

                    };

                    // otherwise, we'll take the % complete to the highest range value, assuming its there
                    // if its not, well just draw 100% complete
                } else {

                    if ($scope.measure.HasDenominator && $scope.measure.Question2Value > 0){

                        var maxValue = entityProjectMeasuresService.getMaxRangeValue($scope.measure.Ranges);
                        $scope.measure.FullValue = ($scope.measure.Question1Value / $scope.measure.Question2Value);
                        $scope.measure.PrettyValue = entityProjectMeasuresService.prettyNumber($scope.measure.FullValue);

                        if (maxValue){
                            $scope.measure.Percentage = Math.round(($scope.measure.FullValue / maxValue) * 100);
                        } else {
                            $scope.measure.Percentage = 100;
                        };

                        entityProjectMeasuresService.setRangesAsPercentage($scope.measure, maxValue);

                    } else if ($scope.measure.HasDenominator && $scope.measure.Question2Value == 0) {

                        $scope.measure.FullValue = 'N/A';
                        $scope.measure.DisplayValue = 'Not Answered';
                        $scope.measure.PrettyValue = 'Not Answered';

                        // This is a pie chart
                    } else if ($scope.measure.Values.length > 0) {
                        $scope.measure.PieData = [];
                        $scope.PieOptions = {
                            showTooltips: false
                        }
                        $scope.PieColors = Chart.defaults.global.colours;
                        
                        angular.forEach($scope.measure.Values, function(value, key) {
                            $scope.measure.PieData.push(value.ValueCount);
                        });
                    } else if ($scope.measure.IsAverage) {

                        if ($scope.measure.TotalResourcesComplete > 0){

                            $scope.measure.FullValue = ($scope.measure.Question1Value / $scope.measure.TotalResourcesComplete);
                            $scope.measure.PrettyValue = entityProjectMeasuresService.prettyNumber($scope.measure.FullValue);
                            $scope.measure.DisplayValue = entityProjectMeasuresService.prettyNumber($scope.measure.FullValue);

                        } else { 

                            $scope.measure.FullValue = 'N/A';
                            $scope.measure.DisplayValue = 'Not Answered';
                            $scope.measure.PrettyValue = 'Not Answered';

                        };

                    } 
                    else {

                        // We're on a profile
                        if ( $scope.measure.TotalResourcesComplete == 0 && $scope.measure.TotalResourcesAvailable == 0 ) {
                            $scope.measure.FullValue = $scope.measure.Question1Value;
                            $scope.measure.PrettyValue = entityProjectMeasuresService.prettyNumber($scope.measure.FullValue);
                            $scope.measure.DisplayValue = entityProjectMeasuresService.prettyNumber($scope.measure.FullValue);
                        } else if ( $scope.measure.TotalResourcesComplete == 0) { // no answers
                            $scope.measure.FullValue = 'N/A';
                            $scope.measure.DisplayValue = 'Not Answered';
                            $scope.measure.PrettyValue = 'Not Answered';
                        } else {
                            $scope.measure.FullValue = $scope.measure.Question1Value;
                            $scope.measure.PrettyValue = entityProjectMeasuresService.prettyNumber($scope.measure.FullValue);
                            $scope.measure.DisplayValue = entityProjectMeasuresService.prettyNumber($scope.measure.FullValue);
                        };

                        

                    }; //  if ($scope.measure.HasDenominator && $scope.measure.Question2Value > 0)

                    var maxValue = entityProjectMeasuresService.getMaxRangeValue($scope.measure.Ranges);
                    if (maxValue){
                        $scope.measure.Percentage = Math.round(($scope.measure.FullValue / maxValue) * 100);
                    } else {
                        $scope.measure.Percentage = 100;
                    };

                    entityProjectMeasuresService.setRangesAsPercentage($scope.measure, maxValue);

                }; //if ($scope.measure.IsPercentage)


                // Cap at 100% or the dial will break
                if ($scope.measure.Percentage > 100) {
                    $scope.measure.Percentage = 100;
                };

                $scope.DrawMeasures($scope.measure);
            }

        }; // initDial

        // Define popovers
        $scope.Popover = {
            templateUrl: 'popover.html',
        };
        $scope.PiePopover = {
            templateUrl: 'pie-popover.html',
        };

        // Draw percentage dials
        $scope.DrawMeasures = function (measure) {
            var count = 0;

            var animateMe = $interval(function() {

                // Increment display value
                if (measure.IsPercentage && (measure.Percentage > count)) {
                    measure.DisplayValue = count;
                    measure.Style = { 'transform': 'rotate(' + count * 3.6 + 'deg)' }
                }
                // We're done
                else {
                    $interval.cancel(animateMe);
                    measure.DisplayValue = $scope.measure.PrettyValue;
                    measure.Style = { 'transform': 'rotate(' + measure.Percentage * 3.6 + 'deg)' }
                };

                $scope.DrawColor(measure);
                count = count + 1;

            }, 25);

            $scope.DrawColor(measure);
        }; //drawMeasures


        // Set the dial color
        $scope.DrawColor = function (measure) {
            // Loop through ranges to see which one we're in and set the matching color
            angular.forEach(measure.Ranges, function(value, key) {
                if (measure.FullValue >= value.Low && measure.FullValue <= value.High) {
                    measure.Color = value.Color;
                };
            });
        }; // DrawColor

        // Set a class with number of characters of the display value
        // so we can adjust the font size in the CSS
        $scope.SetCharCountClass = function (val) {
            // Includes commas and decimals
            var className = 'chars-' + val.toString().length;
            // Need to set a limit
            if ( val.toString().length > 12 ) {
                className = 'chars-12 ellipsis';
            }

            return className;
        };

        $scope.initDial();

    }

  };

});