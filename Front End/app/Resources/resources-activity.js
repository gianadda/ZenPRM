angular.module('App.ResourcesActivityDirective', ['chart.js', 'angular.filter', 'ngTable'])
    .directive('resourcesActivity', function() {

        return {
            restrict: 'E',
            templateUrl: 'Resources/resources-activity.html',
            controller: function($global, $rootScope, $scope, growl, $timeout, RESTService, ChartJs, $filter, $state, NgTableParams, LookupTablesService) {

                $scope.loading = true;

                // Grab data for populating Activity Type dropdown
                $scope.LookupTables = LookupTablesService;

                // Set default dropdown values
                $rootScope.searchCriteria.activityDate = '0';
                $rootScope.searchCriteria.activityTypeGroupIdent = 0;

                // Set pagination defaults
                $scope.CurrentPage = 1;
                $rootScope.searchCriteria.pageChanged = false;
                $rootScope.searchCriteria.resultsShown = 10;

                // Set chart defaults
                $scope.ChartData = [];
                var NestedChartData = [];
                $scope.ChartLabels = [];

                Chart.defaults.global.colours = [
                    '#d47ba7', // pink
                    '#5d8ca9', // blue
                    '#93d3ea', // sky
                    '#e97630', // burnt
                    '#e9cc33', // yellow
                    '#4ea66a', // green
                    '#4d5177' // purple
                ];
                $scope.ChartOptions = {
                    scaleBeginAtZero: true,
                    bezierCurve: false
                }

                // When the search is fired, go fetch the data
                $scope.$on('TimeToStartTheSearch', function(args) {
                    $scope.CurrentPage = 1;
                    $scope.GetActivityData();
                })

                // Go fetch the data
                $scope.GetActivityData = function () {
                    $scope.loading = true;

                    // Hide open details
                    $scope.ShowDetailRow = false;

                    // Do something with the location search
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

                    // Call the API
                    var postEntitySearch = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]) + '/activity', LastSecondSearchCriteria);
                    
                    // On successful request
                    postEntitySearch.then(function(pl) {
                            // Get results because we always need them
                            $scope.ActivityResults = pl.data.Results;

                            if (pl.data.ResultDetails.length > 0) {
                                $scope.ActivityDetails = pl.data.ResultDetails;
                            }

                            // Only do this stuff when we're not paging
                            if ($rootScope.searchCriteria.pageChanged == false) {

                                // Get all the data so we can set up the chart, summaries, etc.
                                $scope.AllResults = pl.data;

                                // Display result count
                                if ($scope.AllResults.ResultCounts && $scope.AllResults.ResultCounts[0].TotalResults !== null) {
                                    $rootScope.searchResultsTotal = $scope.AllResults.ResultCounts[0].TotalResults;
                                } else {
                                    $rootScope.searchResultsTotal = 0;
                                };

                                // Draw the chart
                                $scope.DrawChart();

                                // Set up pagination
                                $scope.TotalActivity = $scope.AllResults.ResultCounts[0].TotalActivity;
                                $scope.ResultsShown = $scope.AllResults.ResultCounts[0].ResultsShown;

                            }

                            $scope.loading = false;

                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                            $scope.loading = false;
                        });
                }

                $scope.DrawChart = function() {
                    // Reset arrays
                    $scope.ChartData = [];
                    NestedChartData = [];
                    $scope.ChartLabels = [];

                    // Selected date range
                    var CurrentDate = $rootScope.searchCriteria.activityDate;

                    // Loop through data and insert into arrays
                    angular.forEach($scope.AllResults.IntervalCounts, function(value, key) {

                        NestedChartData.push(value.TotalCount);

                        // If Today or Yesterday, draw alternating labels
                        if (CurrentDate == 0 || CurrentDate == 1) {
                            if (key % 2 == 0) {
                                $scope.ChartLabels.push(value.Interval + ':00');
                            }
                            else {
                                $scope.ChartLabels.push('');
                            }
                        }
                        // If Last 30 Days, draw alternating labels
                        else if (CurrentDate == 30) {
                            if (key % 2 == 0) {
                                $scope.ChartLabels.push(value.Interval);
                            }
                            else {
                                $scope.ChartLabels.push('');
                            }
                        }
                        else {
                            $scope.ChartLabels.push(value.Interval);
                        }
                    });

                    // Insert nested array per ChartJS specifications
                    $scope.ChartData[0] = NestedChartData;
                }

                // Apply Date or Activity Type filter
                $scope.ApplyFilter = function () {
                    // Reset values if changed due to paging
                    $rootScope.searchCriteria.pageChanged = false;
                    $rootScope.searchCriteria.pageNumber = 1;
                    $scope.CurrentPage = 1;
                    // Send paging values to endpoint
                    $scope.GetActivityData();
                }

                // Get results for current page
                $scope.ChangePage = function () {
                    // Set paging values
                    $rootScope.searchCriteria.pageChanged = true;
                    $rootScope.searchCriteria.pageNumber = $scope.CurrentPage;
                    // Send paging values to endpoint
                    $scope.GetActivityData();
                }

                 // Get results for current page
                $scope.ResultsPerPage = function (num) {
                    // Set paging values
                    $rootScope.searchCriteria.pageChanged = false;
                    $rootScope.searchCriteria.pageNumber = 1;
                    $rootScope.searchCriteria.resultsShown = num;
                    // Send paging values to endpoint
                    $scope.GetActivityData();
                }

                // Format date
                $scope.getMomentDate = function (date) {
                    return moment(date).format('YYYY-MM-DD h:mm:ss A');
                }

                // Show activity details
                $scope.ShowDetailRow = false;

                $scope.ShowDetails = function () {
                    // If there are any details to show
                    if ($scope.ActivityDetails) {
                        // Loop through activity data and append the details, matching on Ident
                        angular.forEach($scope.ActivityResults, function(value, key) {
                            // Filter down to the matching data
                            $scope.MatchingDetail = $filter('filter')($scope.ActivityDetails, { ASUserActivityIdent: value.Ident });
                            // Append to the current object
                            $scope.ActivityResults[key].Detail = $scope.MatchingDetail;
                        });
                    }
                    $scope.ShowDetailRow = !$scope.ShowDetailRow;
                }

                // Get activity data on page load
                $scope.GetActivityData();

            }
        }
    });
