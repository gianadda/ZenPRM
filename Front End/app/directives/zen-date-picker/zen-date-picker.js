angular.module('App.zenDatePicker', ['ui.mask'])
.directive('zenDatePicker', function() {
  return {
    restrict: 'E',
    scope: {
        dateValue: '=',
        id: "@",
        name: "@",
        dateClass: '@'
    },
    templateUrl: 'directives/zen-date-picker/zen-date-picker.html',
    replace: true,
    controller: function ($global, $scope) {

        $scope.initDatePicker = function(){

            $scope.datePickerOpened = false;
            $scope.dateOptions = {
                formatYear: 'yyyy',
                startingDay: 1,
                showWeeks: false
            };

        };

        //Date picker code
        $scope.openDatePicker = function($event) {
            $event.preventDefault();
            $event.stopPropagation();

            $scope.datePickerOpened = !$scope.datePickerOpened;

        };

        $scope.syncDateValue = function(){

            //keep the date value in sync with the displayed value
            $scope.dateValue = $scope.displayValue;

            // if display is null (cleared out), set to undefined, otherwise it causes validation issues
            if ($scope.displayValue == null){

                $scope.displayValue = undefined;
                $scope.dateValue = null;

            };


        };

        $scope.$watch("dateValue", function () {

            // if the display value is not equal to the date value, then sync here
            // this would only happen on an external actor to the control
            // ng-change will keep the values in sync
            if ($scope.dateValue != $scope.displayValue){

                $scope.displayValue = $scope.dateValue;
                
            };

            // if its something, then format the display to be MM/DD/YYYY
            if ($scope.displayValue){ 
                $scope.displayValue = moment($scope.displayValue).format('MM/DD/YYYY');
            };

            // store the dates as YYYY-MM-DD
            if ($scope.dateValue){

                $scope.dateValue = moment($scope.dateValue).format('YYYY-MM-DD');

            };

        });

        $scope.initDatePicker();

    }

  };

});