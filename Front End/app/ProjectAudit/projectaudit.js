angular
    .module('App.ProjectAuditController', ["chart.js"])
    .controller('ProjectAuditController', [
    '$scope',
    '$rootScope',
    '$log',
    '$filter',
    '$timeout',
    '$interval',
    '$http',
    '$global',
    'RESTService',
    'growl',
    '$window',
    'identity',
    'LookupTablesService',
    'MyProfileService',
    'NgTableParams',
    '$sce',
    '$stateParams',
function ($scope, $rootScope, $log, $filter, $timeout, $interval, $http, $global, RESTService, growl, $window, identity, LookupTablesService, MyProfileService, NgTableParams, $sce, $stateParams) {

            $scope.loading = true;

            // Get project ident for loading title and nav
            $rootScope.currentProjectIdent = $stateParams.ident;
            $scope.EntityProject = {};

            // Set pagination defaults
            $scope.CurrentPage = 1;
            $scope.ResultsShown = 10;

            $scope.StartDate = null;
            $scope.EndDate = null; 

            // Watch Start Date date picker and get new data if the value changes
            $scope.$watch('StartDate', function() {
                $scope.GetProjectHistory();
            });

            $scope.$watch('EndDate', function() {
                $scope.GetProjectHistory();
            });

            // Set default values for API request
            $scope.ParticipantIdent = '';
            $scope.ProjectQuestionIdent = '';

            $scope.init = function () {
                // Populate page title and navigation
                if ($rootScope.currentProjectIdent && $rootScope.currentProjectIdent > 0){

                    var getEntityProjectRequirements = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTDETAILS]), $rootScope.currentProjectIdent);

                    getEntityProjectRequirements.then(function (pl) {
                        $scope.EntityProject = pl.data.EntityProject[0];

                        $rootScope.PageTitle = $scope.EntityProject.Name1 + ' - Audit History';
                    });

                }

                // Populate participant typeahead and questions dropdown
                $scope.GetProjectFilterData();

                // Draw results grid
                $scope.GetProjectHistory();

            };

            // Fetch project data from API to fill participant typeahead and questions drowndown
            $scope.GetProjectFilterData = function () {
                // Pass in params to get correct data set
                var searchCriteria = [
                    {
                        name: "bolIncludeParticipants",
                        value: true
                    },
                    {
                        name: "bolIncludeAnswerCount",
                        value: false
                    },
                    {
                        name: "bolIncludeQuestions",
                        value: true
                    }
                ];

                var getEntityProjectRequirements = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTDETAILS]), searchCriteria, $rootScope.currentProjectIdent);

                getEntityProjectRequirements.then(function (pl) {
                        $scope.ProjectParticipantData = pl.data.EntityProjectEntity;
                        $scope.ProjectQuestionData = pl.data.EntityProjectRequirement;
                    },
                    function(errorPL) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            // Fetch proejct history data
            $scope.GetProjectHistory = function () {
                $scope.loading = true;

                // Set parameters to pass into API request
                // We'll always have the number of results to show and the page number
                var params = [
                    {
                        name: "resultsShown",
                        value: $scope.ResultsShown
                    },
                    {
                        name: "pageNumber",
                        value: $scope.CurrentPage
                    }
                ];
                // If we have start and end dates, pass those in too
                if ($scope.StartDate !== null) {
                    params.push(
                        {
                            name: "startDate",
                            value: $scope.FormatDate($scope.StartDate)
                        });
                };

                if ($scope.EndDate !== null) {
                    params.push(
                        {
                            name: "endDate",
                            value: $scope.FormatDate($scope.EndDate)
                        });
                };

                // Get data from API
                var getProjectHistoryData = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + '/' + $stateParams.ident + '/entity' + $scope.ParticipantIdent + '/history' + $scope.ProjectQuestionIdent, params);

                getProjectHistoryData.then(function(pl) {

                        $scope.ProjectHistoryData = pl.data;
                        
                        // Set up pagination
                        $scope.TotalResults = $scope.ProjectHistoryData.resultCounts[0].TotalResults;
                        $scope.ResultsShown = $scope.ProjectHistoryData.resultCounts[0].ResultsShown;

                        $scope.loading = false;
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.loading = false;
                    });

            }

            // Get results for current page
            $scope.ResultsPerPage = function (num) {
                // Set paging values
                $scope.CurrentPage = 1;
                $scope.ResultsShown = num;
                // Reload grid with new results shown
                $scope.GetProjectHistory();
            }

            // Format date
            $scope.FormatDate = function (date) {
                if ( moment(date).isValid() ) {
                    return moment(date).format('MM/DD/YYYY');
                }
                else {
                    return date;
                }
            }

            // Format datetime
            $scope.FormatDateTime = function (date) {
                if ( moment(date).isValid() ) {
                    return moment(date).format('YYYY-MM-DD h:mm:ss A');
                }
                else {
                    return date;
                }
            }

            // Choose provider from typeahead
            $scope.SelectProvider = function (participant) {
                // Build string value for API request
                $scope.ParticipantIdent = '/' + participant.Ident;
                $scope.GetProjectHistory();
            }

            
            // Choose question from dropdown
            $scope.SelectProjectQuestion = function () {
                // Build values for API request
                $scope.ProjectQuestionIdent = '/' + $scope.ProjectQuestions;
                // Need to pass in participant ident or 0
                if ($scope.ParticipantIdent == '') {
                    $scope.ParticipantIdent = '/0';
                }
                $scope.GetProjectHistory();
            }

            // Clear all search filters
            $scope.ClearSearch = function () {
                $scope.StartDate = null;
                $scope.EndDate = null; 
                $scope.ParticipantIdent = '';
                $scope.ProjectQuestionIdent = '';

                $scope.ProjectQuestions = '';
                $scope.SelectParticipant = '';

                $scope.GetProjectHistory();
            }

            // Load resource tooltip on mouseover (ng-mouseenter)
            var timeout;

            $scope.LoadTooltip = function (ResourceIdent, id) {
                // Set timeout so tooltip is not loading when just passing over
                timeout = window.setTimeout(function() {

                    // Set query string parameter
                    var params = [{
                        name: "summaryView",
                        value: "true"
                    }];

                    // Get resource data
                    var getResourceSummary = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY]), params, ResourceIdent);

                    // On successful request
                    getResourceSummary.then(function(pl) {
                        $scope.TooltipData = pl.data.Entity[0];
                        document.getElementById(id).style.display = 'block';
                    });
                }, 250);
            }

            // Turn off tooltip on mouseout (ng-mouseleave)
            $scope.hideTooltip = function (id) {
                clearTimeout(timeout);
                document.getElementById(id).style.display = 'none';
            }

            $scope.init();

    }]);