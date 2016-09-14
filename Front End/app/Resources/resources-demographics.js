angular.module('App.ResourcesDemographicsDirective', ['chart.js', 'angular.filter'])
    .directive('resourcesDemographics', function() {

        return {
            restrict: 'E',
            templateUrl: 'Resources/resources-demographics.html',
            controller: function($global, $rootScope, $scope, growl, $timeout, RESTService, ChartJs, $filter, $state) {

                var intEntitySearchFilterTypeIdentSpecialty = 3;
                var intEntitySearchFilterTypeIdentPayor = 6;
                var intEntitySearchFilterTypeIdentGender = 8;
                $scope.loading = true;

                $scope.NoDataMessage = 'There is not sufficient data to display this report.';

                $scope.$on('TimeToStartTheSearch', function(args) {
                    $scope.loading = true;
                    $scope.GetDemographicData();
                })

                $scope.FilterBySpecialtyAndGender = function(SpecialtyIdent, GenderIdent) {
                    $scope.FilterBySpecialty(SpecialtyIdent, true);
                    $scope.FilterByGender(GenderIdent, true);
                    $scope.loadFilters();
                    $state.go('site.Resources', { Tab: 'grid' });
                }

                $scope.FilterBySpecialty = function(Ident, suppressLoad) {

                    var filter;
                    filter = $filter('filter')($rootScope.$storage.searchFilters, {
                        FilterTypeIdent: intEntitySearchFilterTypeIdentSpecialty,
                        FilterIdent: Ident
                    }, true)[0];

                    if (filter.BitValue) {
                        $rootScope.changeAllFilterStates(item.FilterTypeIdent, false, true);
                        item.Checked = true;
                    } else {
                        filter.Checked = true;
                    }
                    if (!suppressLoad) {
                        $scope.loadFilters();
                        $state.go('site.Resources', { Tab: 'grid' });

                    }

                }

                $scope.FilterByGender = function(Ident, suppressLoad) {

                    var filter;
                    filter = $filter('filter')($rootScope.$storage.searchFilters, {
                        FilterTypeIdent: intEntitySearchFilterTypeIdentGender,
                        FilterIdent: Ident
                    }, true)[0];

                    if (filter.BitValue) {
                        $rootScope.changeAllFilterStates(item.FilterTypeIdent, false, true);
                        item.Checked = true;
                    } else {
                        filter.Checked = true;
                    }
                    if (!suppressLoad) {
                        $scope.loadFilters();
                        $state.go('site.Resources', { Tab: 'grid' });
                    }

                }

                $scope.FilterByPayor = function(Ident, suppressLoad) {

                    var filter;
                    filter = $filter('filter')($rootScope.$storage.searchFilters, {
                        FilterTypeIdent: intEntitySearchFilterTypeIdentPayor,
                        FilterIdent: Ident
                    }, true)[0];

                    if (filter.BitValue) {
                        $rootScope.changeAllFilterStates(item.FilterTypeIdent, false, true);
                        item.Checked = true;
                    } else {
                        filter.Checked = true;
                    }
                    if (!suppressLoad) {
                        $scope.loadFilters();
                        $state.go('site.Resources', { Tab: 'grid' });
                    }

                }

                $scope.GetDemographicData = function() {

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

                    var postEntitySearch = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]) + '/Demographics', LastSecondSearchCriteria);

                    postEntitySearch.then(function(pl) {

                            $scope.DemographicData = pl.data;
                            $scope.loading = false;

                            $rootScope.searchResultsTotal = $scope.DemographicData.ResultCounts[0].TotalResults;

                            // Calculate percentages
                            angular.forEach($scope.DemographicData.TopSpecialties, function(value, key) {
                                value.Percentage = $scope.calculatePercentage(value.ResultCount);
                            });

                            angular.forEach($scope.DemographicData.Gender, function(value, key) {
                                value.Percentage = $scope.calculatePercentage(value.ResultCount);
                            });

                            angular.forEach($scope.DemographicData.TopLanguange, function(value, key) {
                                value.Percentage = $scope.calculatePercentage(value.ResultCount);
                            });

                            $scope.loadChartData();

                            angular.forEach($scope.DemographicData.TopSpecialtiesGenderBreakdown, function(value, key) {
                                value.Percentage = $scope.calculateGenderPercentage(value.ResultCount, value.Column1);
                            });

                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                            $scope.loading = false;
                        });

                }

                $scope.calculatePercentage = function(val) {
                    var percentage = parseFloat(val) / parseFloat($rootScope.searchResultsTotal);
                    percentage = (percentage * 100).toFixed(2);
                    return percentage;
                }

                $scope.calculateGenderPercentage = function(val, specialty) {
                    var filteredTotals = $filter('filter')($scope.SpecialtyTotals, { 'Specialty': specialty });
                    var percentage = parseFloat(val) / parseFloat(filteredTotals[0].Total);
                    percentage = (percentage * 100).toFixed(2);
                    return percentage;
                }

                $scope.loadChartData = function() {

                    // ## Top Specialties vs Sole Providers ## //
                    // Note: Nick did not change the end point to Sole Provider //

                    $scope.TopSpecialtiesSoleProviderLabels = [];
                    $scope.TopSpecialtiesSoleProviderData = [];
                    $scope.DisplayTopSpecialtiesSoleProvider = true;

                    $scope.SpecialtyTotals = [];
                    var SoleProvider_yes = [];
                    var SoleProvider_no = [];
                    var SoleProvider_NA = [];
                    var count = 0;
                    var currSpecialty;
                    var maxLabelLength = 24;

                    if ($scope.DemographicData.TopSpecialtiesVsAcceptingNewPatients.length > 2) {
                        angular.forEach($scope.DemographicData.TopSpecialtiesVsAcceptingNewPatients, function(value, key) {
                            currSpecialty = value.Name1;
                            // Create array of labels
                            if ($scope.TopSpecialtiesSoleProviderLabels.indexOf(currSpecialty) < 0) {
                                $scope.TopSpecialtiesSoleProviderLabels.push(currSpecialty);
                                // Creating object with totals, which also gets used in the Gender Breakdown
                                $scope.SpecialtyTotals.push({ 'Specialty': currSpecialty, 'Total': value.TotalSpecialtyResultCount });
                            }
                            // Put values into correct places in arrays
                            if ($scope.TopSpecialtiesSoleProviderLabels.indexOf(currSpecialty) >= 0) {
                                count = $scope.TopSpecialtiesSoleProviderLabels.indexOf(currSpecialty);
                                if (value.AcceptingNewPatients == 0) {
                                    SoleProvider_no[count] = value.ResultCount;
                                }
                                if (value.AcceptingNewPatients == 1) {
                                    SoleProvider_yes[count] = value.ResultCount;
                                }
                            }
                        });

                        if ($scope.TopSpecialtiesSoleProviderLabels.length < 3) {
                            $scope.DisplayTopSpecialtiesSoleProvider = false;
                        } else {
                            // Loop through specialty totals to calculate N/A (unanswered) values
                            for (var i = 0; i < $scope.SpecialtyTotals.length; i++) {
                                SoleProvider_NA[i] = $scope.SpecialtyTotals[i].Total - SoleProvider_yes[i] - SoleProvider_no[i];
                            }
                            // Loop through specialty lables and trim any that are exceptionally long
                            for (var i = 0; i < $scope.TopSpecialtiesSoleProviderLabels.length; i++) {
                                if ($scope.TopSpecialtiesSoleProviderLabels[i].length > maxLabelLength) {
                                    $scope.TopSpecialtiesSoleProviderLabels[i] = $scope.TopSpecialtiesSoleProviderLabels[i].substring(0, maxLabelLength) + "...";
                                }
                            }
                            // Populate chart data
                            $scope.TopSpecialtiesSoleProviderData[0] = SoleProvider_no;
                            $scope.TopSpecialtiesSoleProviderData[1] = SoleProvider_yes;
                            $scope.TopSpecialtiesSoleProviderData[2] = SoleProvider_NA;
                        }
                    } else {
                        $scope.DisplayTopSpecialtiesSoleProvider = false;
                    }

                    // ## Meaningful Use ## //

                    $scope.MeaningfulUseLabels = [];
                    $scope.MeaningfulUseData = [];
                    $scope.DisplayMeaningfulUse = true;

                    if ($scope.DemographicData.MeaningfulUseTotals.length > 0) {
                        angular.forEach($scope.DemographicData.MeaningfulUseTotals, function(value, key) {
                            if (value.Name1 == '') {
                                $scope.MeaningfulUseLabels.push('Not Provided');
                            } else {
                                $scope.MeaningfulUseLabels.push(value.Name1);
                            }
                            $scope.MeaningfulUseData.push(value.ResultCount);
                        });
                        if ($scope.MeaningfulUseLabels.length == 1 && $scope.MeaningfulUseLabels[0] == 'Not Provided') {
                            $scope.DisplayMeaningfulUse = false;
                            $scope.MeaningfulUseMessage = 'The selected resources have not provided any Meaningful Use data.';
                        }
                    } else {
                        $scope.DisplayMeaningfulUse = false;
                    }

                    // ## Top Payors ## //
                    $scope.SortedPayors = $filter('orderBy')($scope.DemographicData.TopPayors, '-ResultCount');

                    $scope.TopPayorLabelsText = [];
                    $scope.TopPayorLabels = [];
                    $scope.TopPayorData = [];
                    $scope.DisplayTopPayor = true;

                    if ($scope.SortedPayors.length > 0) {
                        angular.forEach($scope.SortedPayors, function(value, key) {

                            // the chart expects an array, not an object array, so were storing just the labels in this array to load into the canvas
                            $scope.TopPayorLabelsText.push(value.Name1);
                            $scope.TopPayorLabels.push({ Ident: value.Ident, text: value.Name1 });
                            $scope.TopPayorData.push(value.ResultCount);
                        });
                    } else {
                        $scope.DisplayTopPayor = false;
                    }
                    $scope.TopPayorLabelsText = $scope.TopPayorLabelsText.slice(0, 7);
                    $scope.TopPayorLabels = $scope.TopPayorLabels.slice(0, 7);
                    $scope.TopPayorData = $scope.TopPayorData.slice(0, 7);

                    // ## Top Language ## //
                    $scope.TopLanguageLabels = [];
                    $scope.TopLanguageData = [];
                    $scope.DisplayTopLanguage = true;

                    if ($scope.DemographicData.TopLanguage.length > 1) {
                        angular.forEach($scope.DemographicData.TopLanguage, function(value, key) {
                            if (key != 0) {
                                $scope.TopLanguageLabels.push(value.Name1);
                                $scope.TopLanguageData.push(value.ResultCount);
                            }
                        });
                    } else {
                        $scope.DisplayTopLanguage = false;
                    }

                    $scope.loading = false;

                }; // loadChartData

                $scope.GetDemographicData();

            }

        }
    });
