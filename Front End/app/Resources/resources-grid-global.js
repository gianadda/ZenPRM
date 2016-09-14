angular.module('App.ResourcesGridGlobalDirective', [])
    .directive('resourcesGridGlobal', function() {

        return {
            restrict: 'E',
            templateUrl: 'Resources/resources-grid-global.html',
            controller: function($global, $rootScope, $scope, growl, $timeout, $filter, RESTService) {

                $scope.updateLimitTo = function() {

                    $scope.searchCriteria.resultsShown = ($scope.searchCriteria.resultsShown + $scope.resultsPageSize);

                    //This is defined in resources.js
                    $scope.searchResources();

                };

                $scope.updateLimitToAll = function() {


                    $scope.searchCriteria.resultsShown = $scope.searchResultsTotal;


                    //This is defined in resources.js
                    $scope.searchResources();

                };


                $scope.CreateCSVOfSelectedSearchResults = function() {

                    var stringOfIdents = '';

                    angular.forEach($scope.searchResults, function(value, key) {

                        if (value.checked) {
                            if (stringOfIdents === '') {
                                stringOfIdents = value.Ident;
                            } else {
                                stringOfIdents = value.Ident + "|" + stringOfIdents;
                            }
                        }
                    });

                    return stringOfIdents;
                }

                $scope.AreAllShowingSearchResultsSelected = function() {


                    var list = $filter('filter')($scope.searchResults, {
                        checked: true
                    }, true)
                    if (list) {
                        if (list.length == $scope.searchCriteria.resultsShown || list.length == $scope.searchResultsTotal) {
                            return true;
                        }
                    }

                    return false;

                }

                $scope.DeselectAllSearchResults = function() {
                    angular.forEach($scope.searchResults, function(value, key) {
                        value.checked = false;
                    });

                };


                $scope.SelectAllSearchResults = function() {
                    angular.forEach($scope.searchResults, function(value, key) {
                        value.checked = true;
                    });

                };

                $scope.GetSelectedSearchResultsCount = function() {


                    $scope.selectedSearchResultsTotal = 0;

                    var list = $filter('filter')($scope.searchResults, {
                        checked: true
                    }, true)
                    if (list) {
                        $scope.selectedSearchResultsTotal = list.length
                    }
                    /*if ($scope.selectedSearchResultsTotal <= 0) {
                        $scope.selectedSearchResultsTotal = $scope.searchResultsTotal;
                    }*/
                    return $scope.selectedSearchResultsTotal;
                };

                $scope.BulkAddToNetwork = function() {

                    var postData = {
                        CSVOfIdents: $scope.CreateCSVOfSelectedSearchResults(),
                        Active: true
                    }

                    if (postData !== '') {


                        var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ADDENTITYTONETWORKBYCSV]), postData);

                        return editPost.then(function(pl) {

                                growl.success($global.GetRandomSuccessMessage())

                            },
                            function(errorPl) {

                                growl.error($global.GetRandomErrorMessage());

                            });

                    }

                };


            }
        };
    });
