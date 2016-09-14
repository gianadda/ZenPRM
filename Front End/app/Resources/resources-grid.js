angular.module('App.ResourcesGridDirective', [])
    .directive('resourcesGrid', function() {

        return {
            restrict: 'E',
            templateUrl: 'Resources/resources-grid.html',
            controller: function($global, $rootScope, $scope, growl, $timeout, $filter, RESTService) {

                $scope.BulkAddToProjectEntityProject = {};

                $scope.ShouldTheSearchResultAttributeRowShow = function(results) {
                    var show = false;
                    angular.forEach(results, function(value, key) {

                        show = show || ($scope.ShouldThisSearchResultAttributeShow(key, value) && angular.isDefined(key) && angular.isDefined(value))

                    })
                    return show;
                }

                $scope.ShouldThisSearchResultAttributeShow = function(attributeKey, attributeValue) {

                    var show = false;

                    angular.forEach($rootScope.$storage.appliedFilters, function(value, key) {

                        if (value.Ident === 3 && attributeKey == 'Specialty') { //'Speciality'
                            show = true;
                        } else if (value.Ident === 2 && attributeKey == 'EntityType') { //'EntityType'
                            show = true;
                        } else if (value.Ident === 6 && attributeKey == 'Payors') { //'Payor'
                            show = true;
                        } else if (value.Ident === 7 && attributeKey == 'Languages') { //'Languages'
                            show = true;
                        } else if (value.Ident === 8 && attributeKey == 'Gender') { //'Gender'
                            show = true;
                        } else if (value.Ident === 9 && attributeKey == 'Degree') { //'Degree'
                            show = true;
                        } else if (value.Ident === 4 && attributeKey == 'AcceptingNewPatients') { //'Accepting New Patients'
                            show = true;
                        } else if (value.Ident === 5 && attributeKey == 'SoleProvider') { //'SoleProvider'
                            show = true;
                        }

                        //Is this anynthing other than our core set of search results?
                        if (['checked', 'lat', 'lng', '$$hashKey', 'AcceptingNewPatients', 'Degree', 'DisplayName', 'Distance', 'Email', 'Gender', 'Ident', 'IsInNetwork', 'Languages', 'NPI', 'Payors', 'Person', 'PrimaryAddress1', 'PrimaryAddress2', 'PrimaryAddress3', 'PrimaryCity', 'AcceptingNewPatients', 'PrimaryState', 'PrimaryZip', 'PrimaryPhone', 'PrimaryPhoneExtension', 'ProfilePhoto', 'SoleProvider', 'Specialty', 'EntityType', 'PrivateResource', 'Registered'].indexOf(attributeKey) == -1) {
                            show = true;
                        }

                    });

                    return show;
                };

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
                    if ($scope.selectedSearchResultsTotal <= 0) {
                        $scope.selectedSearchResultsTotal = $scope.searchResultsTotal;
                    }
                    return $scope.selectedSearchResultsTotal;
                };

                $scope.BulkAddToProject = function() {

                    $scope.searchCriteria.addEntityProjectIdent = $scope.BulkAddToProjectEntityProject.Ident;

                    if ($scope.CreateCSVOfSelectedSearchResults() !== '') {
                        $scope.searchCriteria.addEntityIdents = $scope.CreateCSVOfSelectedSearchResults();

                        $scope.searchResources();

                    } else {
                        // all are selected, so have the db refire search and add to project
                        $scope.searchCriteria.addEntityIdents = undefined;
                        $scope.searchCriteria.addEntityProjectIdent = $scope.BulkAddToProjectEntityProject.Ident;
                        $scope.searchResources();
                    }

                };

                $scope.$on('ResourcesAddedToProject', function(args) {

                    var projectName = '';
                    projectName = $filter('filter')($scope.CurrentEntity.EntityProject, {Ident: $scope.BulkAddToProjectEntityProject.Ident }, true)[0].Name1;

                    growl.success("Congrats! You have added " + $scope.selectedSearchResultsTotal + " Results to the project " + projectName);

                })

            }
        };
    });
