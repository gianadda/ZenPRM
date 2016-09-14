angular.module('App.zenQuestionDrilldown', [])
.directive('zenQuestionDrilldown', function() {
  return {
    restrict: 'E',
    scope: {
        measures: "=",
        measuresView: "=",
        loading: "=",
        dialClass: '@'
    },
    templateUrl: 'directives/zen-question-drilldown/zen-question-drilldown.html',
    controller: function ($scope, $rootScope, growl, $location, $anchorScroll, $stateParams, $filter, NgTableParams, entityProjectMeasuresService, $timeout, RESTService, $global) {

            // It seems like our data wasn't loading quickly enough so let's
            // watch the data to change and then load stuff
            $scope.$watch('measures', function(newVal, oldVal) {
                if (newVal !== oldVal) {
                    $scope.init();
                }
            });

           // $scope.viewClass = $scope.dialClass;

            $scope.init = function () {
                $scope.ReloadGrid = false;

                // Load measures data
                $scope.MeasuresData = $scope.measures;
                $scope.DialsData = $scope.MeasuresData.Dials;
                // Need to know if we're dealing with a percentage or a number
                $scope.MeasureHasDenominator = $scope.DialsData[0].HasDenominator;
                $scope.MeasureIsPercentage = $scope.DialsData[0].IsPercentage;
                $scope.MeasureQuestion1RequirementTypeIdent = $scope.DialsData[0].Question1RequirementTypeIdent;
                
                // Set current tab
                $scope.CurrentTab = $scope.measuresView;

                if ( $scope.CurrentTab == 'dials' ) {
                    // Timeout necessary to draw value in sub title
                    $timeout(function() {
                        $scope.MeasureClick($scope.DialsData[0], true);
                    }, 0);
                }
                else {
                    // Need some of the basic measure data
                    $scope.DrawParticipants($scope.DialsData[0]);
                }

                //
            }

            // Handle measure click
            $scope.MeasureClick = function (measure, firstLoad) {
                // Deselect measure if clicked a second time
                if (measure.Selected == true) {
                    measure.Selected = false;
                    $scope.selectionMode = false;
                }
                // Select current measure
                else {
                    // Deselect any other selected measures
                    angular.forEach($scope.DialsData, function(value, key) {
                        value.Selected = false;
                    });
                    measure.Selected = true;
                    $scope.selectionMode = true;
                    $scope.OrgName = measure.MeasureName;
                    
                    if (measure.HasDenominator == true) {
                        $scope.OrgValue = measure.Percentage + '%';
                    }
                    else {
                        $scope.OrgValue = measure.DisplayValue;
                    }

                    $scope.DrawParticipants(measure);

                    // Scroll down to participants
                    if (!firstLoad) {
                        $location.hash('Participants');
                        $anchorScroll();
                    }
                }
            }

            // Draw participants grid

            $scope.$watch("ReloadGrid", function () {
                $scope.tableParams.reload();
                $scope.ReloadGrid = false;
            });

            // Set up table params
            $scope.ParticipantsData = [];
            var orderedData;
            var fullOrderedData;

            $scope.tableParams = new NgTableParams({
                page: 1, // show first page
                count: 10, // count per page
                sorting: {
                    Answer: 'desc',
                    DisplayName: 'asc'
                }
            }, {
                counts: [5, 10, 25, 50, 100],
                getData: function (params) {

                    orderedData = $scope.ParticipantsData;

                    //First do the sorting
                    orderedData = params.sorting() ? $filter('orderBy')(orderedData, params.orderBy()) : orderedData;

                    //Then the filtering
                    orderedData = params.filter() ? $filter('filter')(orderedData, params.filter()) : orderedData;

                    // Hide Org column on Dials tab
                    if ( $scope.CurrentTab == 'dials' ) {
                        params.ShowOrgCol = false;
                    }
                    else {
                        params.ShowOrgCol = true;
                    }

                    fullOrderedData = orderedData;

                    params.settings().total = orderedData.length;

                    //Then the paging
                    orderedData = orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count());

                    return orderedData;
                }

            });

            // Filter down participants and calculate answers
            $scope.DrawParticipants = function (measure) {

                if ( $scope.CurrentTab == 'dials') {
                    $scope.ParticipantsData = $filter('filter')($scope.MeasuresData.Participants, { OrganizationIdent: measure.OrganizationIdent}, true);
                }
                else {

                    // group by the entity
                    var groupedParticipants = $filter('groupBy')($scope.MeasuresData.Participants, "EntityIdent");

                    // then loop through and concat all orgs to this participant record
                    angular.forEach(groupedParticipants, function(value, key){

                        var participant = null;

                        angular.forEach(value, function(iValue, iKey){

                            if (!participant){
                                participant = {};
                                participant = iValue;
                            } else {
                                participant.Organization += ", " + iValue.Organization;
                            };

                        });

                        $scope.ParticipantsData.push(participant);

                    });

                };
                
                angular.forEach($scope.ParticipantsData, function(participant) {

                    // if we're displaying file data, let the user download the file here
                    if (participant.IsFileUpload){

                        participant.downloadLink = $scope.getFileLink(participant.EntityIdent, participant.AnswerIdent);

                    };

                    // Check to make sure that the participant has answered the question
                    if (participant.Answered == true) {
                        // If this is a measure with a denominator (percentage, ratio, etc.)
                        // Only applies to Measures, not individual questions
                        if (measure.HasDenominator == true) {

                            if (measure.IsPercentage == true){
                                participant.FullValue = (participant.Value1 / participant.Value2) * 100;
                                participant.Answer = parseFloat(Math.round(participant.FullValue));

                                // Color the bar
                                angular.forEach(measure.Ranges, function(range) {
                                    if (participant.Answer >= range.Low && participant.Answer <= range.High) {
                                        participant.Color = range.Color;
                                    }
                                });

                            } else {
                                var maxValue = entityProjectMeasuresService.getMaxRangeValue(measure.Ranges);
                                participant.FullValue = (participant.Value1 / participant.Value2);

                                if (maxValue){

                                    participant.Percentage = (participant.FullValue / maxValue) * 100;

                                } else {

                                    participant.Percentage = 100;

                                };

                                if (participant.Percentage > 100){
                                    participant.Percentage = 100;
                                }
                                
                                participant.Answer = parseFloat(participant.FullValue.toFixed(2));

                                entityProjectMeasuresService.setRangesAsPercentage(measure, maxValue);

                                // Color the bar
                                angular.forEach(measure.Ranges, function(range) {
                                    if (participant.Answer >= range.Low && participant.Answer <= range.High) {
                                        participant.Color = range.Color;
                                    }
                                });

                            }; //if (measure.IsPercentage 

                            // Make it pretty
                            participant.AnswerDisplay = entityProjectMeasuresService.prettyNumber(participant.Answer);

                        } // has denominator
                        else {
                            
                            if (participant.Value1String){

                                participant.Answer = participant.Value1String;
                                participant.AnswerDisplay = participant.Value1String;

                            } else {

                                participant.Answer = parseFloat(participant.Value1);
                                // Make it pretty
                                participant.AnswerDisplay = entityProjectMeasuresService.prettyNumber(participant.Answer);
                            };

                        }
                    }
                    else {
                        // just for sorting
                        participant.Answer = -100000000;
                    };

                }); // forEach

                $scope.ReloadGrid = true;
            }; // Draw Participants

            $scope.getFileLink = function(entityIdent, answerIdent){

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITY,entityIdent,$global.RESTControllerNames.FILES,answerIdent]);

                return URI;

            };


    }

  };

});