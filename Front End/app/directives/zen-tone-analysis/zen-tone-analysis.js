angular.module('App.zenToneAnalysis', ['chart.js'])
.directive('zenToneAnalysis', function() {
  return {
    restrict: 'E',
    scope: {
        ident: '=',
        name: '=',
        text: '=',
        btnClass: '='
    },
    templateUrl: 'directives/zen-tone-analysis/zen-tone-analysis.html',
    controller: function ($scope, $modal, zenWatsonService, ChartJs) {

        $scope.Accepted = false;
        $scope.ShowAnalysis = false;
        $scope.ShowError = false;
        $scope.Loading = false;

        $scope.OpenModal = function () {
            
            $scope.ToneModal = $modal.open({
                animation: true,
                templateUrl: 'ToneModal.html',
                size: 'lg',
                scope: $scope
            });

        }

        $scope.GetWatson = function() {
            $scope.Loading = true;

            // Analysis of all answers to an individual question
            if ($scope.ident) {

                zenWatsonService.postToneByQuestionIdent($scope.ident).then(function WatsonQuestionGood(response) {
                    if (response) {
                        FormatData(response);
                    }
                    else {
                        $scope.ShowError = true;
                    }

                    $scope.Loading = false;

                },
                function WatsonQuestionError(response) {
                    $scope.ShowError = true;
                    $scope.Loading = false;
                });

            }

            // Analysis of supplied text
            if ($scope.text) {

                zenWatsonService.postTone($scope.text).then(function WatsonTextGood(response) {
                    if (response) {
                        FormatData(response);
                    }
                    else {
                        $scope.ShowError = true;
                    }

                    $scope.Loading = false;

                },
                function WatsonTextError(response) {
                    $scope.ShowError = true;
                    $scope.Loading = false;
                });
            }
        }

        var FormatData = function(data) {
            $scope.ToneData = data;

            $scope.CatNames = [];
            $scope.ChartLabels = [];
            $scope.ChartData = [];

            // Let's make some charts!
            angular.forEach($scope.ToneData.document_tone.tone_categories, function(value, key) {
                var count = 0;
                var toneArr = value.tones;
                var labelArr = toneArr.map(function MapArr(obj) {
                    return obj.tone_name;
                });
                var dataArr = toneArr.map(function MapArr(obj) {
                    count++;
                    return obj.score * 100;
                });

                if (count > 0) {
                    $scope.CatNames.push(value.category_name);
                    $scope.ChartLabels.push(labelArr);
                    $scope.ChartData.push([dataArr]);
                }
            });

            $scope.ShowAnalysis = true;
        }


        $scope.percentify = function(num) {
            var percent = parseFloat(num) * 100;
            percent = Math.round(percent);
            return percent;
        }

    }

  };

});