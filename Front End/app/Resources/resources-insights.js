angular.module('App.ResourcesInsightsDirective', [])
    .directive('resourcesInsights', function() {

        return {
            restrict: 'E',
            templateUrl: 'Resources/resources-insights.html',
            controller: function($global, $rootScope, $scope, growl, $timeout, RESTService, $sessionStorage, $filter) {

                $scope.isValidSearchCriteria = false;


                //Setup session storage into scope so that we can save out search criteria when we leave the screen and come back
                $rootScope.$storage = $sessionStorage;

                $scope.$on('TimeToStartTheSearch', function(args) {
                    $scope.setValidSearchCriteria()
                    if ($scope.isValidSearchCriteria) {

                        if (!$scope.loading) {
                            $scope.GetInsightData();
                        }
                    }
                })

                $scope.setValidSearchCriteria = function() {

                    if ($scope.searchCriteria.XAxisEntityProjectRequirementIdent ||
                        $scope.searchCriteria.YAxisEntityProjectRequirementIdent ||
                        $scope.searchCriteria.ZAxisEntityProjectRequirementIdent ||
                        $scope.searchCriteria.AlphaAxisEntityProjectRequirementIdent) {
                        $scope.isValidSearchCriteria = true;
                    } else {
                        $scope.isValidSearchCriteria = false;
                    }

                }

                $scope.SetAxisDataType = function(axis) {
                    if ($scope.XAxisEntityProjectRequirement) {
                        if (axis == 'x') {
                            $scope.XAxisDataTypeIdent = $scope.XAxisEntityProjectRequirement.EntitySearchDataTypeIdent;
                            $scope.searchCriteria.XAxisEntityProjectRequirementIdent = $scope.XAxisEntityProjectRequirement.Ident;

                            $rootScope.$storage.Insights.LastSelectedXAxisEntityProjectIdent = $scope.searchCriteria.XAxisEntityProjectIdent;
                            $rootScope.$storage.Insights.LastSelectedXAxisEntityProjectRequirementIdent = $scope.XAxisEntityProjectRequirement.Ident;
                        } else if (axis == 'y') {
                            $scope.YAxisDataTypeIdent = $scope.YAxisEntityProjectRequirement.EntitySearchDataTypeIdent;
                            $scope.searchCriteria.YAxisEntityProjectRequirementIdent = $scope.YAxisEntityProjectRequirement.Ident;

                            $rootScope.$storage.Insights.LastSelectedYAxisEntityProjectIdent = $scope.searchCriteria.YAxisEntityProjectIdent;
                            $rootScope.$storage.Insights.LastSelectedYAxisEntityProjectRequirementIdent = $scope.YAxisEntityProjectRequirement.Ident;
                        } else if (axis == 'z') {
                            $scope.ZAxisDataTypeIdent = $scope.ZAxisEntityProjectRequirement.EntitySearchDataTypeIdent;
                            $scope.searchCriteria.ZAxisEntityProjectRequirementIdent = $scope.ZAxisEntityProjectRequirement.Ident;

                            $rootScope.$storage.Insights.LastSelectedZAxisEntityProjectIdent = $scope.searchCriteria.ZAxisEntityProjectIdent;
                            $rootScope.$storage.Insights.LastSelectedZAxisEntityProjectRequirementIdent = $scope.ZAxisEntityProjectRequirement.Ident;
                        } else if (axis == 'aplha') {
                            $scope.AlphaAxisDataTypeIdent = $scope.AlphaAxisEntityProjectRequirement.EntitySearchDataTypeIdent;
                            $scope.searchCriteria.AlphaAxisEntityProjectRequirementIdent = $scope.AlphaAxisEntityProjectRequirement.Ident;

                            $rootScope.$storage.Insights.LastSelectedAlphaAxisEntityProjectIdent = $scope.searchCriteria.AlphaAxisEntityProjectIdent;
                            $rootScope.$storage.Insights.LastSelectedAlphaAxisEntityProjectRequirementIdent = $scope.AlphaAxisEntityProjectRequirement.Ident;
                        }
                    }
                    $scope.setValidSearchCriteria();
                }

                var colorArray = [
                    //Black for N/A
                    "#76689b",
                    //$brand-purple",
                    "#4d5177",
                    //$brand-blue",
                    "#5d8ca9",
                    //$brand-sky",
                    "#93d3ea",
                    //$brand-teal",
                    "#67c0ce",
                    //$brand-green",
                    "#4ea66a",
                    //$brand-lime",
                    "#94c371",
                    //$brand-yellow",
                    "#e9cc33",
                    //$brand-orange",
                    "#e29e0a",
                    //$brand-burnt",
                    "#e97630",
                    //$brand-rust",
                    "#af4723",
                    //$brand-red",
                    "#ce605a",
                    //$brand-pink",
                    "#d47ba7",
                    //Generated at http://www.cssdrive.com/
                    "#fcdd81",
                    "#eaea76",
                    "#f9cb6b",
                    "#f4ac46",
                    "#f5c291",
                    "#b8ca2f",
                    "#b6b20b",
                    "#ec8871",
                    "#c5dc82",
                    "#b3d37c",
                    "#8db525",
                    "#e99dbc",
                    "#f3aec6",
                    "#5d8ca9",
                    "#bee1db",
                    "#88bbdc",
                    "#7a9cc9}",
                    "#dab5d1"

                ];
                var colorScale = colorArray.concat(d3.scale.category20c());

                $scope.colorFunction = function() {
                    return function(d, i, graph) {
                        return colorArray[d.AlphaIndex];
                    };
                }

                $scope.tooltipXContentFunction = function(d) {
                    return function(key, x, y, graph) {

                        var tooltipText = '';
                        var outerX = x;
                        var outerY = y;
                        angular.forEach(graph.series.values, function(value, key) {

                            if ((d3.round(value.XValue, 2) == outerX && d3.round(value.YValue, 2) == outerY) || ($scope.getCleanedDate(moment(value.XValue)) == $scope.getCleanedDate(moment(outerX)) && $scope.getCleanedDate(moment(value.YValue)) == $scope.getCleanedDate(moment(outerY)))) {
                                tooltipText = tooltipText + '<p><strong>' + value.DisplayName + '</strong></p>'
                            }

                        })


                        return tooltipText + '<p>Color: ' + graph.point.Alpha + '</p><p>Size: ' + graph.point.size + '</p>'
                    }
                }

                $scope.callbackFunction = function() {

                    return function(chart) {
                        //This is really important, it allows a scatter chart to have multiple points at the same X/Y
                        chart.useVoronoi(false);
                        $scope.Chart = chart;
                        //console.log('inner callback function', chart);

                    }
                };

                $scope.getShapeCross = function() {
                    return function(d) {
                        return 'cross';
                    }
                }
                $scope.yAxisTickFormatFunction = function() {
                    return function(d) {
                        var textToDisplay;
                        //BIT
                        if ($scope.YAxisDataTypeIdent == 1) {

                            textToDisplay = d3.round(d, 2);

                        } else if ($scope.YAxisDataTypeIdent == 3) {
                            if (d % 1 == 0) {
                                textToDisplay = $scope.getCleanedDate(moment(new Date()).add(d, 'days'));
                            }
                        } else if ($scope.YAxisDataTypeIdent == 5) {
                            if (d == 1) {
                                textToDisplay = 'Yes';
                            } else if (d == 0) {
                                textToDisplay = 'No';
                            }
                        }

                        return textToDisplay; //d3.round(d, 2)
                        //return d3.time.format('%x')(new Date(d));
                    }
                }

                $scope.getCleanedDate = function(date) {


                    if (date == '') {
                        return '';
                    } else if (moment(date).format('MM/DD/YYYY') !== '01/01/1900') {
                        return moment(date).format('MM/DD/YYYY');
                    } else {
                        return '';
                    }

                }

                $scope.xAxisTickFormatFunction = function() {
                    return function(d) {
                        var textToDisplay;
                        //BIT
                        if ($scope.XAxisDataTypeIdent == 1) {

                            textToDisplay = d3.round(d, 2);

                        } else if ($scope.XAxisDataTypeIdent == 3) {
                            if (d % 1 == 0) {
                                textToDisplay = $scope.getCleanedDate(moment(new Date()).add(d, 'days'));
                            }
                        } else if ($scope.XAxisDataTypeIdent == 5) {
                            if (d == 1) {
                                textToDisplay = 'Yes';
                            } else if (d == 0) {
                                textToDisplay = 'No';
                            }
                        }

                        return textToDisplay; //d3.round(d, 2)
                        //return d3.time.format('%x')(new Date(d));
                    }
                }


                $scope.GetInsightData = function() {

                    $scope.loading = true;


                    if ($rootScope.searchCriteria.radius == 'Unknown') {
                        $rootScope.searchCriteria.location = '';
                        $rootScope.searchCriteria.latitude = 1.00000;
                        $rootScope.searchCriteria.longitude = 1.00000;
                    }
                    var LastSecondSearchCriteria;
                    LastSecondSearchCriteria = angular.copy($rootScope.searchCriteria);
                    if (LastSecondSearchCriteria.radius == 'Unknown') {
                        LastSecondSearchCriteria.radius = 100;
                    }


                    var postEntitySearch = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]) + '/Insights', LastSecondSearchCriteria);

                    postEntitySearch.then(function(pl) {

                            $scope.baseData = pl.data.Entities;


                            if (pl.data && pl.data.ResultCounts) {

                                $rootScope.searchResultsTotal = pl.data.ResultCounts[0].TotalResults;

                            } else {

                                // something happened, return 0 results
                                $rootScope.searchResultsTotal = 0;
                            };

                            angular.forEach($scope.baseData, function(value, key) {
                                if ($scope.XAxisDataTypeIdent == 3) {
                                    if ($scope.baseData[key].x && $scope.baseData[key].x !== "0") {
                                        $scope.baseData[key].x = moment($scope.baseData[key].x).diff(moment(), 'days');
                                    }
                                }
                                if ($scope.YAxisDataTypeIdent == 3) {
                                    if ($scope.baseData[key].y && $scope.baseData[key].y !== "0") {
                                        $scope.baseData[key].y = moment($scope.baseData[key].y).diff(moment(), 'days');
                                    }
                                }

                            })

                            // $scope.ZAxisDataTypeIdent 

                            //first group it by the Alpha property (i.e. Groups)
                            $scope.baseData = $filter('groupBy')($scope.baseData, 'Alpha');

                            var groupCounter = 0;
                            //Now let's loop throught the groups adding the needed tags and sub nodes
                            angular.forEach($scope.baseData, function(value, key) {
                                    var values = angular.copy($scope.baseData[key]);

                                    $scope.baseData[key] = {};
                                    $scope.baseData[key].key = key;
                                    $scope.baseData[key].AlphaValue = key;
                                    $scope.baseData[key].AlphaIndex = groupCounter;
                                    $scope.baseData[key].values = $filter('orderBy')(values, 'x');
                                    groupCounter += 1;

                                })
                                //Now let's turn this into an array so that the NVd3JS library has what it needs.
                            $scope.baseData = $filter('toArray')($scope.baseData);

                            console.log($scope.baseData);
                            //For Dates
                            /*                            if ($scope.Chart) {
                                                            $scope.Chart.xScale(d3.time.scale.utc());
                                                            $scope.Chart.scatter.xScale(d3.time.scale.utc());

                                                        }*/
                            $scope.chartData = $scope.baseData;

                            $scope.loading = false;
                            $scope.fullScreenLoading = false;

                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                            $scope.loading = false;
                            $scope.fullScreenLoading = false;
                        });


                }



                $scope.LoadProjectQuestionsByAxis = function(EntityProjectIdent, Axis) {

                    if (EntityProjectIdent) {
                        var getEntityProject = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), EntityProjectIdent);

                        getEntityProject.then(function(pl) {
                                if (Axis == 'x') {
                                    $scope.XAxisEntityProjectQuestions = pl.data.EntityProjectRequirement;

                                    if (EntityProjectIdent == $rootScope.$storage.Insights.LastSelectedXAxisEntityProjectIdent) {

                                        $scope.XAxisEntityProjectRequirement = $filter('filter')($scope.XAxisEntityProjectQuestions, { 'Ident': $rootScope.$storage.Insights.LastSelectedXAxisEntityProjectRequirementIdent }, true)[0];
                                        $scope.searchCriteria.XAxisEntityProjectRequirementIdent = $rootScope.$storage.Insights.LastSelectedXAxisEntityProjectRequirementIdent;

                                    } else {
                                        $scope.XAxisEntityProjectRequirement = 0;
                                        $scope.searchCriteria.XAxisEntityProjectRequirementIdent = 0;
                                    }

                                } else if (Axis == 'y') {
                                    $scope.YAxisEntityProjectQuestions = pl.data.EntityProjectRequirement;

                                    if (EntityProjectIdent == $rootScope.$storage.Insights.LastSelectedYAxisEntityProjectIdent) {
                                        $scope.YAxisEntityProjectRequirement = $rootScope.$storage.Insights.LastSelectedYAxisEntityProjectRequirementIdent;
                                        $scope.searchCriteria.YAxisEntityProjectRequirementIdent = $rootScope.$storage.Insights.LastSelectedYAxisEntityProjectRequirementIdent;
                                    } else {
                                        $scope.YAxisEntityProjectRequirement = 0;
                                        $scope.searchCriteria.YAxisEntityProjectRequirementIdent = 0;
                                    }
                                } else if (Axis == 'z') {
                                    $scope.ZAxisEntityProjectQuestions = pl.data.EntityProjectRequirement;

                                    if (EntityProjectIdent == $rootScope.$storage.Insights.LastSelectedZAxisEntityProjectIdent) {
                                        $scope.ZAxisEntityProjectRequirement = $rootScope.$storage.Insights.LastSelectedZAxisEntityProjectRequirementIdent;
                                        $scope.searchCriteria.ZAxisEntityProjectRequirementIdent = $rootScope.$storage.Insights.LastSelectedZAxisEntityProjectRequirementIdent;
                                    } else {
                                        $scope.ZAxisEntityProjectRequirement = 0;
                                        $scope.searchCriteria.ZAxisEntityProjectRequirementIdent = 0;
                                    }
                                } else if (Axis == 'alpha') {
                                    $scope.AlphaAxisEntityProjectQuestions = pl.data.EntityProjectRequirement;

                                    if (EntityProjectIdent == $rootScope.$storage.Insights.LastSelectedAlphaAAxisEntityProjectIdent) {
                                        $scope.AlphaAxisEntityProjectRequirement = $rootScope.$storage.Insights.LastSelectedAlphaAxisEntityProjectRequirementIdent;
                                        $scope.searchCriteria.AlphaAAxisEntityProjectRequirementIdent = $rootScope.$storage.Insights.LastSelectedAlphaAAxisEntityProjectRequirementIdent;
                                    } else {
                                        $scope.AlphaAxisEntityProjectRequirement = 0;
                                        $scope.searchCriteria.AlphaAxisEntityProjectRequirementIdent = 0;
                                    }
                                }
                            },
                            function(errorPl) {
                                growl.error($global.GetRandomErrorMessage());
                            });
                    }

                }; // LoadProjectQuestionsByAxis

                if (!$rootScope.$storage.Insights) {
                    $rootScope.$storage.Insights = {};
                    //Projects
                    $rootScope.$storage.Insights.LastSelectedXAxisEntityProjectIdent;
                    $rootScope.$storage.Insights.LastSelectedYAxisEntityProjectIdent;
                    $rootScope.$storage.Insights.LastSelectedZAxisEntityProjectIdent;
                    $rootScope.$storage.Insights.LastSelectedAlphaAxisEntityProjectIdent;

                    //Questions
                    $rootScope.$storage.Insights.LastSelectedXAxisEntityProjectRequirementIdent;
                    $rootScope.$storage.Insights.LastSelectedYAxisEntityProjectRequirementIdent;
                    $rootScope.$storage.Insights.LastSelectedZAxisEntityProjectRequirementIdent;
                    $rootScope.$storage.Insights.LastSelectedAlphaAxisEntityProjectRequirementIdent;

                } else {
                    $scope.searchCriteria.XAxisEntityProjectIdent = $rootScope.$storage.Insights.LastSelectedXAxisEntityProjectIdent;
                    $scope.LoadProjectQuestionsByAxis($rootScope.$storage.Insights.LastSelectedXAxisEntityProjectIdent, 'x');

                    $scope.searchCriteria.YAxisEntityProjectIdent = $rootScope.$storage.Insights.LastSelectedYAxisEntityProjectIdent;
                    $scope.LoadProjectQuestionsByAxis($rootScope.$storage.Insights.LastSelectedYAxisEntityProjectIdent, 'y');

                    $scope.searchCriteria.ZAxisEntityProjectIdent = $rootScope.$storage.Insights.LastSelectedZAxisEntityProjectIdent;
                    $scope.LoadProjectQuestionsByAxis($rootScope.$storage.Insights.LastSelectedZAxisEntityProjectIdent, 'z');

                    $scope.searchCriteria.AlphaAxisEntityProjectIdent = $rootScope.$storage.Insights.LastSelectedAlphaAxisEntityProjectIdent;
                    $scope.LoadProjectQuestionsByAxis($rootScope.$storage.Insights.LastSelectedAlphaAAxisEntityProjectIdent, 'alpha');
                }


            $scope.GetInsightData();

            } 

        };
    })

.filter('filterWithOr', function($filter) {
    var comparator = function(actual, expected) {
        if (angular.isUndefined(actual)) {
            // No substring matching against `undefined`
            return false;
        }
        if ((actual === null) || (expected === null)) {
            // No substring matching against `null`; only match against `null`
            return actual === expected;
        }
        if ((angular.isObject(expected) && !angular.isArray(expected)) || (angular.isObject(actual) && !hasCustomToString(actual))) {
            // Should not compare primitives against objects, unless they have custom `toString` method
            return false;
        }

        actual = angular.lowercase('' + actual);
        if (angular.isArray(expected)) {
            var match = false;
            expected.forEach(function(e) {
                e = angular.lowercase('' + e);
                if (actual.indexOf(e) !== -1) {
                    match = true;
                }
            });
            return match;
        } else {
            expected = angular.lowercase('' + expected);
            return actual.indexOf(expected) !== -1;
        }
    };
    return function(campaigns, filters) {
        return $filter('filter')(campaigns, filters, comparator);
    };
});
