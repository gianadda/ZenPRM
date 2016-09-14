'use strict'

angular.module('App.ResourcesController', [])
    .controller('ResourcesController', [
        'entityService', 'geocodingService', '$global', 'identity', 'LookupTablesService', '$modal', 'MyProfileService', 'RESTService', '$rootScope', '$scope', '$sessionStorage', '$state', '$stateParams', '$filter', '$timeout', 'growl','entityNetworkService', 'NgTableParams',
        function(entityService, geocodingService, $global, identity, LookupTablesService, $modal, MyProfileService, RESTService, $rootScope, $scope, $sessionStorage, $state, $stateParams, $filter, $timeout, growl, entityNetworkService, NgTableParams) {

            $scope.toggleMenu = false;
            $scope.toggleSavedSearchMenu = false;
            $scope.csvDownloadLink = '';


            //What tab are we on? //default to grid
            $scope.currentTab = 'grid';
            if ($stateParams.Tab) {
                $scope.currentTab = $stateParams.Tab;
            };


            //If we are on the Global URL, set the global for searching. NOTE: this is not in session storage so that it gets cleard on page changes
            if ($state.$current.url.prefix == '/globalresources/') {
                $scope.Global = true;
            } else {
                $scope.Global = false;
            };
            if ($stateParams.Global) {
                $scope.Global = true;
                if ($stateParams.Tab == "") {
                    $scope.currentTab = 'grid';
                }
            };

            //For search results, are we showing compact or Expanded 
            $scope.view = 'compact';

            //What should we set the radius of the search to if the user puts in a zipcode or ends up on the global screen
            $scope.defaultRadius = 5;

            //This is the loaction at the last time we did the geocode lookup
            $scope.LocationAsOfLastGeoCode = '';

            //Setup lookup tables into Scope
            $scope.LookupTablesService = LookupTablesService;

            //Setup session storage into scope so that we can save out search criteria when we leave the screen and come back
            $rootScope.$storage = $sessionStorage;

            //variables to store the applied filters, these will show to the user
            $rootScope.$storage.appliedFilters = [];

            //Loading screen vars
            $scope.loading = false;
            $scope.fullScreenLoading = false;

            //search critera that will be sent to server on Search
            if (!$rootScope.searchCriteria) {
                $rootScope.searchCriteria = {};
                $rootScope.searchCriteria.radius = $scope.defaultRadius;
            } else {
                if ($scope.Global == false) {

                    if ($rootScope.LastPageIWasOn == '/globalresources/') {

                        $rootScope.searchCriteria.location = '';
                        $rootScope.searchCriteria.radius = $scope.defaultRadius;
                        $rootScope.searchCriteria.latitude = 0.0;
                        $rootScope.searchCriteria.longitude = 0.0;
                    }

                }
            }


            $rootScope.LastPageIWasOn = $state.$current.url.prefix;

            $rootScope.searchCriteriaAsOfLastSearch = {};

            $rootScope.searchCriteria.resultsShown = 10;
            $rootScope.searchCriteria.searchGlobal = $scope.Global;
            $scope.resultsLimit = 10;
            $scope.resultsPageSize = 10;
            $rootScope.searchResultsTotal = 0;
            $rootScope.entitySearchHistoryIdent = 0;

            //Ensure that there is a debounce on the search
            var timeoutPromise;
            var timeoutPromiseLocation;
            var delayInMs = 2000
            var delayInMsLocation = 500;

            // Set page title
            // Global
            if ( $scope.currentTab == 'grid' && $scope.Global == true ) {
                $rootScope.PageTitle = 'Global Resources';
            }
            if ( $scope.currentTab == 'map' && $scope.Global == true ) {
                $rootScope.PageTitle = 'Global Resources - Map';
            }
            // My Resources
            if ( $scope.currentTab == 'grid' && $scope.Global == false ) {
                $rootScope.PageTitle = 'My Resources';
            }
            if ( $scope.currentTab == 'map' && $scope.Global == false ) {
                $rootScope.PageTitle = 'My Resources - Map';
            }
            if ( $scope.currentTab == 'insights' && $scope.Global == false ) {
                $rootScope.PageTitle = 'My Resources - Insights';
            }
            if ( $scope.currentTab == 'demographics' && $scope.Global == false ) {
                $rootScope.PageTitle = 'My Resources - Demographics';
            }
            if ( $scope.currentTab == 'activity' && $scope.Global == false ) {
                $rootScope.PageTitle = 'My Resources - Activity';
            }


            $scope.displayDownloadMessage = function(){

                growl.success("Your file is in the process of downloading. Please remain on this page until the download has completed.");

            };

            $scope.init = function() {

                $scope.loading = true;

                //Let's go get the current logged in user to populate a few items
                identity.identity()
                    .then(function() {
                        $scope.MyIdent = identity.getUserIdent();
                        MyProfileService.getProfile($scope.MyIdent).then(function(pl) {

                                $scope.CurrentEntity = pl;

                                //Autoset to the first project
                                if ($scope.CurrentEntity.EntityProject.length > 0) {
                                    $scope.BulkAddToProjectEntityProjectIdent = $scope.CurrentEntity.EntityProject[0];
                                }

                                if (!$rootScope.searchCriteria) {
                                    //initialize the search criteria
                                    $scope.initSearchCriteria();
                                }
                                //if this is a global search, set the location to the user's zipcode and set the default radius
                                if ($scope.Global && !$rootScope.searchCriteria.location) {
                                    $rootScope.searchCriteria.location = $scope.CurrentEntity.Entity[0].PrimaryZip;
                                    $rootScope.searchCriteria.latitude = $scope.CurrentEntity.Entity[0].Latitude;
                                    $rootScope.searchCriteria.longitude = $scope.CurrentEntity.Entity[0].Longitude;
                                    $rootScope.searchCriteria.radius = $scope.defaultRadius;
                                };

                                $scope.getEntityOrganizations();

                                //Let's go get the data for the filters
                                $scope.getFilterData();

                                //Now let's load them up to be displayed
                                $scope.loadFilters();

                                //Go to the server and load up any saved searches into scope to be displayed
                                $scope.GetSavedSearches();


                                $scope.GeoCodeLocation();

                            },
                            function(errorPl) {
                                growl.error($global.GetRandomErrorMessage());
                            });
                    });


            };

            $scope.getEntityOrganizations = function(){

                entityNetworkService.getEntityNetworkNonPersonResoures().then(function (data) {

                    $rootScope.NewHierarchySpecificFilter = {};
                    $rootScope.NewHierarchySpecificFilter.Organizations = data;

                }); //entityHierarchyService.getEntityNetworkNonPersonResoures


            };

            $scope.initSearchCriteria = function() {
                //Setup the default Search Criteria and it will get overridden by session storage after
                $rootScope.searchCriteria.keyword = '';
                $rootScope.searchCriteria.searchGlobal = $scope.Global;
                $rootScope.searchCriteria.location = '';
                $rootScope.searchCriteria.radius = $scope.defaultRadius;
                $rootScope.searchCriteria.latitude = 0.0;
                $rootScope.searchCriteria.longitude = 0.0;
                $rootScope.searchCriteria.keyword = '';
                $rootScope.searchCriteria.addEntityIdents = '';
                $rootScope.searchCriteria.filters = [];
                $rootScope.searchCriteria.fullProjectExport = false;

                $rootScope.searchCriteria.name = undefined;
                $rootScope.CurrentSaveSearchName = undefined;
                $rootScope.CurrentSavedSearchIdent = undefined;
            };


            $scope.SetRadius = function(radius) {
                $rootScope.searchCriteria.radius = radius;
            };

            $scope.searchResources = function() {

                $scope.loading = true;
                $scope.$broadcast('SearchProcessBegins');

                if ($scope.currentTab == 'grid' || $scope.currentTab == 'map') {

                    if ((angular.isDefined($rootScope.searchCriteria.location) && $rootScope.searchCriteria.location !== '') && (angular.isUndefined($rootScope.searchCriteria.radius) || $rootScope.searchCriteria.radius == 0)) {
                        $rootScope.searchCriteria.radius = $scope.defaultRadius;
                    } else if (angular.isUndefined($rootScope.searchCriteria.location)) {
                        $rootScope.searchCriteria.radius = undefined;
                    };

                    if ($scope.LocationAsOfLastGeoCode !== $rootScope.searchCriteria.location) {
                        $scope.GeoCodeLocation();

                    } else {

                        $scope.search();

                    };

                } else {
                    $scope.GeoCodeLocation(true);

                }; // if grid or map

            }; // searchResources

            $scope.GeoCodeLocation = function(broadcastOnly) {

                $scope.LocationAsOfLastGeoCode = $rootScope.searchCriteria.location;

                if ($rootScope.searchCriteria.radius == 'Unknown') {
                    $rootScope.searchCriteria.location = '';
                    $rootScope.searchCriteria.latitude = 1.00000;
                    $rootScope.searchCriteria.longitude = 1.00000;
                    $scope.search();
                } else if ($rootScope.searchCriteria.location) {

                    geocodingService.getLocationGeoCodes($rootScope.searchCriteria.location).then(function(pl) {
                        $rootScope.searchCriteria.latitude = pl.latitude;
                        $rootScope.searchCriteria.longitude = pl.longitude;

                        if (broadcastOnly) {

                            // if re-firing the search, then reset the paging
                            $rootScope.searchCriteria.pageChanged = false;
                            $rootScope.searchCriteria.pageNumber = 1;

                            $scope.$broadcast('TimeToStartTheSearch');
                        } else {
                            $scope.search();
                        };

                    }); //geocodingService

                } else if (!$scope.Global) {

                    if (broadcastOnly) {

                        // if re-firing the search, then reset the paging
                        $rootScope.searchCriteria.pageChanged = false;
                        $rootScope.searchCriteria.pageNumber = 1;

                        $scope.$broadcast('TimeToStartTheSearch');
                    } else {
                        $scope.search();
                    };

                }; // if ($rootScope.searchCriteria.radius == 'Unknown')


            }; // GeoCodeLocation


            /* -------------------------------------------------------------- */
            /* FILTERS */


            //Get the data for Filtering and put it in to $rootScope
            $scope.getFilterData = function() {


                if (!$rootScope.$storage.searchFilters) {

                    $rootScope.$storage.searchFilters = [];

                };

                if (!$rootScope.$storage.projectSpecificFilters) {

                    $rootScope.$storage.projectSpecificFilters = [];

                };

                if (!$rootScope.$storage.hierarchySpecificFilters) {

                    $rootScope.$storage.hierarchySpecificFilters = [];

                };

                if (!$rootScope.$storage.AcceptingNewPatientFilters || $rootScope.$storage.AcceptingNewPatientFilters.length === 0) {
                    $rootScope.$storage.AcceptingNewPatientFilters = [{
                        Name1: "Yes",
                        checked: false
                    }, {
                        Name1: "No",
                        checked: false
                    }];
                }

                if (!$rootScope.$storage.SoleProviderFilters || $rootScope.$storage.SoleProviderFilters.length === 0) {
                    $rootScope.$storage.SoleProviderFilters = [{
                        Name1: "Yes",
                        checked: false
                    }, {
                        Name1: "No",
                        checked: false
                    }];
                }

                if (!$rootScope.$storage.RegisteredUserFilters || $rootScope.$storage.RegisteredUserFilters.length === 0) {
                    $rootScope.$storage.RegisteredUserFilters = [{
                        Name1: "Yes",
                        checked: false
                    }, {
                        Name1: "No",
                        checked: false
                    }];
                }

                if(!$rootScope.$storage.HierarchyTypeFilters || $rootScope.$storage.HierarchyTypeFilters.length === 0){
                   $rootScope.$storage.HierarchyTypeFilters = $scope.LookupTablesService.HierarchyType; 
                }

                // copy in the lookup tables into local vars so we can set selected states
                if (!$rootScope.$storage.EntityTypeFilters || $rootScope.$storage.EntityTypeFilters.length === 0) {
                    $rootScope.$storage.EntityTypeFilters = $scope.LookupTablesService.EntityType;
                }
                if (!$rootScope.$storage.SpecialtyFilters || $rootScope.$storage.SpecialtyFilters.length === 0) {
                    $rootScope.$storage.SpecialtyFilters = $scope.LookupTablesService.Speciality;
                }
                if (!$rootScope.$storage.PayorFilters || $rootScope.$storage.PayorFilters.length === 0) {
                    $rootScope.$storage.PayorFilters = $scope.LookupTablesService.Payor;
                }
                if (!$rootScope.$storage.LanguageFilters || $rootScope.$storage.LanguageFilters.length === 0) {
                    $rootScope.$storage.LanguageFilters = $scope.LookupTablesService.Language;
                }
                if (!$rootScope.$storage.GenderFilters || $rootScope.$storage.GenderFilters.length === 0) {
                    $rootScope.$storage.GenderFilters = $scope.LookupTablesService.Gender;
                }
                if (!$rootScope.$storage.DegreeFilters || $rootScope.$storage.DegreeFilters.length === 0) {
                    $rootScope.$storage.DegreeFilters = $scope.LookupTablesService.Degree;
                }
                if (!$rootScope.$storage.EntitySearchDataTypes || $rootScope.$storage.EntitySearchDataTypes.length === 0) {
                    $rootScope.$storage.EntitySearchDataTypes = $scope.LookupTablesService.EntitySearchDataType;
                }
                if (!$rootScope.$storage.EntitySearchFilterTypes || $rootScope.$storage.EntitySearchFilterTypes.length === 0) {
                    $rootScope.$storage.EntitySearchFilterTypes = $scope.LookupTablesService.EntitySearchFilterType;
                }
                if (!$rootScope.$storage.EntitySearchOperators || $rootScope.$storage.EntitySearchOperators.length === 0) {
                    $rootScope.$storage.EntitySearchOperators = $scope.LookupTablesService.EntitySearchOperator;
                }

                var CurrentEntitySearchFilterTypeDataSet = [];
                var CurrentEntitySearchFilterTypeName = '';

                if ($rootScope.$storage.searchFilters.length == 0) {

                    angular.forEach($scope.LookupTablesService.EntitySearchFilterType, function(value, key) {

                        // reset the data object for the loop
                        CurrentEntitySearchFilterTypeDataSet = [];
                        CurrentEntitySearchFilterTypeName = '';

                        if (value.Ident === 3) { //'Speciality'
                            CurrentEntitySearchFilterTypeDataSet = $rootScope.$storage.SpecialtyFilters;
                            CurrentEntitySearchFilterTypeName = 'Speciality'

                        } else if (value.Ident === 6) { //'Payor'
                            CurrentEntitySearchFilterTypeDataSet = $rootScope.$storage.PayorFilters;
                            CurrentEntitySearchFilterTypeName = 'Payor'

                        } else if (value.Ident === 7) { //'Language1'
                            CurrentEntitySearchFilterTypeDataSet = $rootScope.$storage.LanguageFilters;
                            CurrentEntitySearchFilterTypeName = 'Language1'

                        } else if (value.Ident === 8) { //'Gender'
                            CurrentEntitySearchFilterTypeDataSet = $rootScope.$storage.GenderFilters;
                            CurrentEntitySearchFilterTypeName = 'Gender'

                        } else if (value.Ident === 9) { //'Degree'
                            CurrentEntitySearchFilterTypeDataSet = $rootScope.$storage.DegreeFilters;
                            CurrentEntitySearchFilterTypeName = 'Degree'

                        } else if (value.Ident === 2) { //'EntityType'
                            CurrentEntitySearchFilterTypeDataSet = $rootScope.$storage.EntityTypeFilters;
                            CurrentEntitySearchFilterTypeName = 'EntityType'

                        } else if (value.Ident === 4) { //'Accepting New Patients'
                            CurrentEntitySearchFilterTypeDataSet = $rootScope.$storage.AcceptingNewPatientFilters;
                            CurrentEntitySearchFilterTypeName = 'AcceptingNewPatient'

                        } else if (value.Ident === 5) { //'SoleProvider'
                            CurrentEntitySearchFilterTypeDataSet = $rootScope.$storage.SoleProviderFilters;
                            CurrentEntitySearchFilterTypeName = 'SoleProvider'

                        } else if (value.Ident === 10) { //'RegisteredUsers'
                            CurrentEntitySearchFilterTypeDataSet = $rootScope.$storage.RegisteredUserFilters;
                            CurrentEntitySearchFilterTypeName = 'RegisteredUsers'

                        };

                        angular.forEach(CurrentEntitySearchFilterTypeDataSet, function(innerValue, innerKey) {
                            if (innerValue.Ident !== 0) {
                                $rootScope.$storage.searchFilters.push({
                                    FilterTypeIdent: value.Ident,
                                    FilterType: CurrentEntitySearchFilterTypeName,
                                    FilterIdent: innerValue.Ident,
                                    FilterName1: innerValue.Name1,
                                    Checked: false,
                                    BitValue: value.BitValue,
                                    ProjectSpecific: value.ProjectSpecific,
                                    HierarchySpecific: value.HierarchySpecific,
                                    ReferenceTable: value.ReferenceTable
                                })
                            };
                        });

                    });
                }
            };

            //Get the filter data and put it into a single array to be displayed on screen as tags
            $scope.loadFilters = function() {

                var CurrentEntitySearchFilterTypeDataSet = [];
                $rootScope.$storage.appliedFilters = [];

                /*
                Add all of the project specific filters
                */
                angular.forEach($rootScope.$storage.projectSpecificFilters, function(value, key) {

                    if (value.EntityProjectRequirement && value.Project) {

                        var Filter = {};
                        Filter.Ident = 1; //Project Specific
                        Filter.Count = 0;
                        if (value.EntitySearchOperator) {
                            Filter.entitySearchOperatorIdent = value.EntitySearchOperator.Ident;
                            Filter.searchValue = value.EntitySearchOperator.value;

                            if (value.EntitySearchOperator.Name1 == 'Is On Project') {
                                Filter.FullText = value.Project.Name1 + ' - ' + value.EntityProjectRequirement.label;
                            } else {
                                Filter.FullText = value.Project.Name1 + ' - ' + value.EntityProjectRequirement.label + ' ' + value.EntitySearchOperator.Name1;
                            }

                            if (angular.isObject(value.EntitySearchOperator.value)) {
                                angular.forEach(value.EntitySearchOperator.value, function(value, key) {
                                    if (Filter.Count == 0) {
                                        Filter.FullText = Filter.FullText + ': ' + key
                                    } else {
                                        Filter.FullText = Filter.FullText + ', ' + key
                                    }
                                    Filter.Count += 1;
                                });
                            } else {
                                if (value.EntitySearchOperator.value) {
                                    Filter.FullText = Filter.FullText + ': ' + value.EntitySearchOperator.value
                                }
                            }

                        } else {
                            Filter.entitySearchOperatorIdent = 0;
                            Filter.searchValue = undefined
                            Filter.FullText = value.Project.Name1 + ' - ' + value.EntityProjectRequirement.label;
                        }
                        Filter.entityProjectRequirementIdent = value.EntityProjectRequirement.Ident;
                        Filter.referenceIdent = value.Project.Ident;

                        Filter.ShortText = Filter.FullText;

                        if (Filter.FullText.length > 30) {
                            if (Filter.Count > 0) {
                                Filter.ShortText = value.Project.Name1 + ' (' + Filter.Count + ')';
                            } else {

                                Filter.ShortText = value.Project.Name1
                            }
                        }
                        Filter.Name1 = Filter.FullText;
                        $rootScope.$storage.appliedFilters.push(Filter);
                    } // if (value.EntityProjectRequirement && value.Project)
                    else if (value.EntitySearchOperator && value.EntitySearchOperator.EntitySearchDataTypeIdent == 9) { // email

                        var Filter = {};
                        Filter.Ident = 12; // email
                        Filter.Count = 1;

                        Filter.entitySearchOperatorIdent = value.EntitySearchOperator.Ident;
                        Filter.searchValue = value.EntitySearchOperator.value;
                        Filter.FullText = 'Email';
                        Filter.ShortText = Filter.FullText;

                        if (value.EntitySearchOperator.value){

                            Filter.FullText = Filter.FullText + ': ' + value.EntitySearchOperator.Name1 + ' ' + value.EntitySearchOperator.value;

                        } else {
                            Filter.FullText = Filter.FullText + ': ' + value.EntitySearchOperator.Name1;
                        };

                        $rootScope.$storage.appliedFilters.push(Filter);

                    };

                });

                // hierarchySpecificFilters
                angular.forEach($rootScope.$storage.hierarchySpecificFilters, function(value, key) {

                    var Filter = {};
                    Filter.ShortText = '';
                    Filter.FullText = '';
                    Filter.Name1 = '';
                    Filter.Count = 0;
                    Filter.Ident = 11; // organizations
                    Filter.searchValue = {};
                    Filter.referenceIdent = 0;

                    var orgs = value.ToEntityIdents.split('|');
                    var orgText = '';

                    angular.forEach(orgs, function(innerValue, innerKey) {

                        if (innerValue != ''){

                            Filter.Count += 1;

                            if ($rootScope.NewHierarchySpecificFilter && $rootScope.NewHierarchySpecificFilter.Organizations){

                                orgText = $filter('filter')($rootScope.NewHierarchySpecificFilter.Organizations, {EntityIdent: parseInt(innerValue)}, true)[0].DisplayName;

                            };

                            if (orgText != '' && Filter.FullText == '') {
                                Filter.FullText = 'Organizations: ' + orgText;
                            } else {
                                Filter.FullText += ' or ' + orgText;
                            };

                        }; // if innerValue

                    }); //angular.forEach(orgs

                    if (Filter.Count > 0) {

                        Filter.Name1 = Filter.FullText;

                        if (Filter.FullText.length > 30) {
                            Filter.ShortText = ' Organizations (' + Filter.Count + ')';
                        } else {
                            Filter.ShortText = Filter.FullText;
                        };

                        Filter.searchValue = value.ToEntityIdents;
                        Filter.referenceIdent = value.HierarchyTypeIdent.Ident;
                        $rootScope.$storage.appliedFilters.push(Filter);
                    }

                }); //angular.forEach($rootScope.$storage.hierarchySpecificFilters

                /*
                For Every filter type, loop through the 
                */
                angular.forEach($rootScope.$storage.EntitySearchFilterTypes, function(value, key) {

                    var Filter = {};
                    Filter.ShortText = '';
                    Filter.FullText = '';
                    Filter.Name1 = '';
                    Filter.Count = 0;
                    Filter.Ident = 0;
                    Filter.searchValue = {};

                    angular.forEach($rootScope.$storage.searchFilters, function(innerValue, innerKey) {

                        if (value.Ident == innerValue.FilterTypeIdent) {

                            Filter.Ident = innerValue.FilterTypeIdent;

                            if (innerValue.Checked) {

                                Filter.Count += 1;
                                if (innerValue.BitValue) {
                                    if (innerValue.FilterName1 == 'Yes') {
                                        Filter.searchValue[innerValue.FilterIdent] = 'True';
                                    } else {
                                        Filter.searchValue[innerValue.FilterIdent] = 'False';

                                    }
                                } else {
                                    Filter.searchValue[innerValue.FilterIdent] = innerValue.Checked;

                                }
                                if (Filter.FullText == '') {
                                    if (innerValue.FilterName1) {
                                        Filter.FullText = value.Name1 + ': ' + innerValue.FilterName1;

                                    } else {
                                        Filter.FullText = value.Name1;

                                    }
                                } else {
                                    Filter.FullText = Filter.FullText + ' or ' + innerValue.FilterName1;
                                }

                                Filter.ShortText = Filter.FullText;

                                if (Filter.FullText.length > 30) {
                                    Filter.ShortText = value.Name1 + ' (' + Filter.Count + ')';
                                }

                                Filter.FilterTypeIdent = innerValue.FilterTypeIdent;


                            }

                        }

                    }); //angular.forEach($rootScope.$storage.EntitySearchFilterTypes


                    if (Filter.Count > 0) {

                        $rootScope.$storage.appliedFilters.push(Filter);
                    }

                });
                $scope.applyFilters();
                return $rootScope.$storage.appliedFilters;
            };

            // take the filters that have been setup and add them into $rootScope.searchCriteria..filters
            $scope.applyFilters = function() {
                $rootScope.searchCriteria.filters = [];
                /*
                              For Every filter type, loop through the 
                              */
                angular.forEach($rootScope.$storage.appliedFilters, function(value, key) {

                    var addFilter = {};
                    addFilter.entitySearchFilterTypeIdent = value.Ident;

                    //Project Specific
                    if (value.Ident == 1) {
                        addFilter.entitySearchOperatorIdent = value.entitySearchOperatorIdent;
                        addFilter.entityProjectRequirementIdent = value.entityProjectRequirementIdent;
                        addFilter.referenceIdent = value.referenceIdent;
                        addFilter.searchValue = '';
                        //END Project Specific 
                    } else if (value.Ident == 11) { //Hierarchy Specific
                        addFilter.entitySearchOperatorIdent = 0;
                        addFilter.entityProjectRequirementIdent = 0;
                        addFilter.referenceIdent = value.referenceIdent;
                        addFilter.searchValue = '';
                        //END Hieararchy Specific 
                    } else if (value.Ident == 12) { //Email
                        addFilter.entitySearchOperatorIdent = value.entitySearchOperatorIdent;
                        addFilter.entityProjectRequirementIdent = 0;
                        addFilter.referenceIdent = 0;
                        addFilter.searchValue = '';
                        //END Email
                    } else {
                        addFilter.entitySearchOperatorIdent = 0;
                        addFilter.entityProjectRequirementIdent = 0;
                        addFilter.referenceIdent = 0;
                        addFilter.searchValue = '';

                    }

                    // need to check isDate first since date objects will pass isObject check
                    if (angular.isDate(value.searchValue)) {

                        addFilter.searchValue = value.searchValue.toLocaleString().replace(',', '');

                    } else if (angular.isObject(value.searchValue)) {
                        angular.forEach(value.searchValue, function(innerValue, innerKey) {
                            if (innerValue == true) {
                                if (addFilter.searchValue == '') {

                                    addFilter.searchValue = innerKey
                                } else {
                                    addFilter.searchValue = addFilter.searchValue + '|' + innerKey
                                }
                            } else {
                                if (addFilter.searchValue == '') {
                                    addFilter.searchValue = innerValue
                                } else {
                                    addFilter.searchValue = addFilter.searchValue + '|' + innerValue
                                }

                            };
                        });
                    } else {
                        addFilter.searchValue = value.searchValue;

                    }



                    $rootScope.searchCriteria.filters.push(addFilter);

                });

            }


            $scope.ClearFilters = function(bolSkipSearch) {
                $scope.initSearchCriteria()

                angular.forEach($rootScope.$storage.EntitySearchFilterTypes, function(value, key) {
                    value.FilterTypeIdent = value.Ident;
                    $scope.RemoveFilter(value);
                })
                $rootScope.$storage.projectSpecificFilters = [];
                $rootScope.$storage.hierarchySpecificFilters = [];
                $scope.loadFilters();

                if (!bolSkipSearch) {

                    // if global search, then reset to default so the search doesn't hang
                    if ($scope.Global){
                        $rootScope.searchCriteria.location = $scope.CurrentEntity.Entity[0].PrimaryZip;
                        $rootScope.searchCriteria.latitude = $scope.CurrentEntity.Entity[0].Latitude;
                        $rootScope.searchCriteria.longitude = $scope.CurrentEntity.Entity[0].Longitude;
                        $rootScope.searchCriteria.radius = $scope.defaultRadius;
                    };

                    $scope.searchResources();

                };

                $scope.toggleSavedSearchMenu = false;

            }; // clear filters


            // this will work with any of the filters
            $rootScope.changeSingleFilterState = function(item, ignoreLoadFilters) {

                if (item.BitValue) {

                    $rootScope.changeAllFilterStates(item.FilterTypeIdent, false, true);
                    item.Checked = true;

                } else {
                    if (item.Checked) {
                        item.Checked = false;
                    } else {
                        item.Checked = true;
                    }
                }

                if (!ignoreLoadFilters){
                    $scope.loadFilters();
                };

            };

            // this will work with any of the filters 
            $rootScope.changeAllFilterStates = function(FilterTypeIdent, selected, overrideAll) {

                angular.forEach($rootScope.$storage.searchFilters, function(value, key) {

                    if (value.FilterTypeIdent === FilterTypeIdent && (value.count > 0 || overrideAll)) {
                        value.Checked = selected;
                    };

                });

                $scope.loadFilters();
            };


            //remove an individual filter
            $scope.RemoveFilter = function(filter, reloadSearch) {
                if (filter.Ident == 1) {
                    var index = -1;
                    angular.forEach($rootScope.$storage.projectSpecificFilters, function(value, key) {
                        if (value.EntityProjectRequirement) {
                            if (filter.entityProjectRequirementIdent === value.EntityProjectRequirement.Ident &&
                                filter.referenceIdent === value.Project.Ident) {

                                if (value.EntitySearchOperator) {

                                    if (filter.entitySearchOperatorIdent === value.EntitySearchOperator.Ident &&
                                        filter.searchValue === value.EntitySearchOperator.value) {
                                        index = key;
                                    } else if (filter.entitySearchOperatorIdent == 0) {
                                        index = key;
                                    }
                                } else if (filter.entitySearchOperatorIdent == 0) {
                                    index = key;
                                }
                            }
                        }
                    })
                    if (index >= 0) {
                        $rootScope.$storage.projectSpecificFilters.splice(index, 1);
                        $scope.loadFilters();
                    }

                    // hierarchy specific
                } else if (filter.Ident == 11) {
                    var index = -1;
                    angular.forEach($rootScope.$storage.hierarchySpecificFilters, function(value, key) {
                            if (filter.searchValue == value.ToEntityIdents && filter.referenceIdent == value.HierarchyTypeIdent.Ident) {
                                index = key;
                            }

                    })
                    if (index >= 0) {
                        $rootScope.$storage.hierarchySpecificFilters.splice(index, 1);
                        $scope.loadFilters();
                    }

                } else if (filter.Ident == 12) { // email
                    var index = -1;

                    angular.forEach($rootScope.$storage.projectSpecificFilters, function(value, key) {
                        if (value.EntitySearchOperator) {
                            if (value.EntitySearchOperator.Ident === filter.entitySearchOperatorIdent &&
                                (!value.EntitySearchOperator.value || (value.EntitySearchOperator.value == filter.searchValue))) {
                                index = key;
                            }
                        }
                    })

                    if (index >= 0) {
                        $rootScope.$storage.projectSpecificFilters.splice(index, 1);
                        $scope.loadFilters();
                    }
                    

                }  else {
                    $rootScope.changeAllFilterStates(filter.Ident, false, true);
                };

                if (reloadSearch) {

                    $scope.searchResources();

                };

            };


            $scope.showFilterSearchResultsModal = function(CurrentEntitySearchFilterType) {

                $rootScope.CurrentEntitySearchFilterType = CurrentEntitySearchFilterType;
                $rootScope.EntityProject = $scope.CurrentEntity.EntityProject;

                $rootScope.NewProjectSpecificFilter = {};
                $rootScope.NewHierarchySpecificFilter = {};

                if (CurrentEntitySearchFilterType.ProjectSpecific == true) {

                    //(Setup) the modal and keep it in scope so we can call functions on it.
                    $rootScope.FilterProjectSpecificSearchResults = $modal.open({
                        animation: true,
                        templateUrl: 'FilterProjectSpecificSearchResults.html',
                        scope: $rootScope,
                        size: 'lg'
                    });

                    $rootScope.$watch('NewProjectSpecificFilter.Project', function() {
                        if ($rootScope.NewProjectSpecificFilter.Project) {
                            if ($rootScope.NewProjectSpecificFilter.Project.Ident > 0) {
                                $rootScope.GetProjectQuestions($rootScope.NewProjectSpecificFilter.Project.Ident);
                            }
                        }
                    });


                    $rootScope.ValidToAddFilter = function() {
                        if ($rootScope.NewProjectSpecificFilter.Project && $rootScope.NewProjectSpecificFilter.EntityProjectRequirement && $rootScope.NewProjectSpecificFilter.EntitySearchOperator) {
                            if ($rootScope.NewProjectSpecificFilter.EntitySearchOperator.ShowProjectQuestionFilter == false) {
                                return true;
                            }
                        }
                        return true;
                    }

                    $rootScope.GetProjectQuestions = function(EntityProjectIdent) {

                        var getEntityProject = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), EntityProjectIdent);

                        getEntityProject.then(function(pl) {
                                $rootScope.EntityProjectQuestions = [];
                                $rootScope.EntityProjectQuestions.push({
                                    EntityProjectIdent: 10086,
                                    EntitySearchDataTypeIdent: 1,
                                    entitySearchOperatorIdent: 1,
                                    Ident: 0,
                                    RequirementTypeIdent: 1,
                                    RequiresAnswer: true,
                                    description: "",
                                    helpText: "",
                                    label: "Is On Project",
                                    model: 0,
                                    options: "",
                                    placeholder: "",
                                    sortOrder: 2,
                                    submitted: false,
                                    type: "",
                                    values: ""
                                });

                                $rootScope.EntityProjectQuestions = $rootScope.EntityProjectQuestions.concat(pl.data.EntityProjectRequirement);



                            },
                            function(errorPl) {
                                growl.error($global.GetRandomErrorMessage());
                            });

                    }


                    //Create an "Ok" function to close the modal.
                    $rootScope.FilterProjectSpecificSearchResults.ok = function() {

                        //add the actual filter
                        if ($rootScope.NewProjectSpecificFilter.EntityProjectRequirement.Ident == 0 && !angular.isDefined($rootScope.NewProjectSpecificFilter.EntitySearchOperator)) {

                            //This means we want to just see if they are on the project
                            $rootScope.NewProjectSpecificFilter.EntitySearchOperator = {
                                EntitySearchDataTypeIdent: 1,
                                Ident: 1,
                                Name1: "Is On Project",
                                ShowProjectQuestionFilter: false,
                                value: undefined
                            };
                        }

                        $rootScope.$storage.projectSpecificFilters.push(angular.copy($rootScope.NewProjectSpecificFilter));

                        $rootScope.NewProjectSpecificFilter = {};
                        $rootScope.CurrentEntitySearchFilterType = undefined;
                        $scope.loadFilters();
                        $rootScope.FilterProjectSpecificSearchResults.close();
                        $scope.searchResources();

                    };
                    //Create a "Cancel" function to close the modal.
                    $rootScope.FilterProjectSpecificSearchResults.clear = function() {

                        $rootScope.NewProjectSpecificFilter = {};
                        $scope.RemoveFilter($rootScope.CurrentEntitySearchFilterType)
                        $scope.loadFilters();
                        $scope.searchResources();
                    };

                    // Email
                } else if (CurrentEntitySearchFilterType.Ident == 12) {


                    //(Setup) the modal and keep it in scope so we can call functions on it.
                    $rootScope.FilterEmailSearchResults = $modal.open({
                        animation: true,
                        templateUrl: 'FilterEmailSearchResults.html',
                        scope: $rootScope,
                        size: 'lg'
                    });

                    //Create an "Ok" function to close the modal.
                    $rootScope.FilterEmailSearchResults.ok = function() {

                        //add the actual filter
                        $rootScope.$storage.projectSpecificFilters.push(angular.copy($rootScope.NewProjectSpecificFilter));

                        $rootScope.NewProjectSpecificFilter = {};
                        $rootScope.CurrentEntitySearchFilterType = undefined;
                        $scope.loadFilters();
                        $rootScope.FilterEmailSearchResults.close();
                        $scope.searchResources();

                    }; // FilterEmailSearchResults.ok


                    //Create a "Cancel" function to close the modal.
                    $rootScope.FilterEmailSearchResults.clear = function() {

                        $rootScope.NewProjectSpecificFilter = {};
                        $scope.loadFilters();
                        $scope.searchResources();
                    }; // FilterEmailSearchResults.clear


                    $rootScope.ValidEmailFilter = function() {

                        if ($rootScope.NewProjectSpecificFilter.EntitySearchOperator){

                            // if we've selected an operator and we dont need to add a value, then we are valid
                            if (!$rootScope.NewProjectSpecificFilter.EntitySearchOperator.ShowProjectQuestionFilter){

                                return true;

                            } else {

                                // once we add the value, we're valid
                                if ($rootScope.NewProjectSpecificFilter.EntitySearchOperator.value){

                                    return true;

                                };

                            };

                        };

                    }; // ValidEmailFilter


                } else if (CurrentEntitySearchFilterType.HierarchySpecific == true) {

                    //(Setup) the modal and keep it in scope so we can call functions on it.
                    $rootScope.FilterHierarchySearchResultsModal = $modal.open({
                        animation: true,
                        templateUrl: 'FilterHierarchySearchResults.html',
                        scope: $rootScope,
                        size: 'lg'
                    });

                    $scope.getEntityOrganizations();

                    //Create an "Ok" function to close the modal.
                    $rootScope.FilterHierarchySearchResultsModal.ok = function() {

                        var Idents = '';

                        angular.forEach($rootScope.NewHierarchySpecificFilter.Organizations, function(value, key) {

                            if (value.Checked){

                                Idents += value.EntityIdent + '|';

                            };

                        });

                        $rootScope.NewHierarchySpecificFilter.ToEntityIdents = Idents;
                        $rootScope.$storage.hierarchySpecificFilters.push(angular.copy($rootScope.NewHierarchySpecificFilter));

                        $rootScope.NewHierarchySpecificFilter.ToEntityIdents = null;
                        $rootScope.NewHierarchySpecificFilter.HierarchyTypeIdent = {};

                        angular.forEach($rootScope.NewHierarchySpecificFilter.Organizations, function(value, key) {

                            if (value.Checked){

                                value.Checked = false;

                            };

                        });

                        //$rootScope.CurrentEntitySearchFilterType = undefined;
                        $scope.loadFilters();
                        $rootScope.FilterHierarchySearchResultsModal.close();
                        $scope.searchResources();

                    };
                    //Create a "Cancel" function to close the modal.
                    $rootScope.FilterHierarchySearchResultsModal.clear = function() {

                        $rootScope.NewHierarchySpecificFilter.ToEntityIdents = null;
                        $rootScope.NewHierarchySpecificFilter.HierarchyTypeIdent = {};

                        angular.forEach($rootScope.NewHierarchySpecificFilter.Organizations, function(value, key) {

                            if (value.Checked){

                                value.Checked = false;

                            };

                        });

                        //$scope.RemoveFilter($rootScope.CurrentEntitySearchFilterType);
                        $scope.loadFilters();
                        $scope.searchResources();
                    };

                } else {

                    //(Setup) the modal and keep it in scope so we can call functions on it.
                    $rootScope.FilterSearchResultsModal = $modal.open({
                        animation: true,
                        templateUrl: 'FilterSearchResults.html',
                        scope: $rootScope,
                        size: 'lg'
                    });
                    //Create an "Ok" function to close the modal.
                    $rootScope.FilterSearchResultsModal.ok = function() {

                        $rootScope.CurrentEntitySearchFilterType = undefined;
                        $scope.loadFilters();
                        $rootScope.FilterSearchResultsModal.close();
                        $scope.searchResources();
                    };
                    //Create a "Cancel" function to close the modal.
                    $rootScope.FilterSearchResultsModal.clear = function() {

                        $scope.RemoveFilter($rootScope.CurrentEntitySearchFilterType);
                        $scope.loadFilters();
                        $scope.searchResources();
                    };

                }
            };


            /* -------------------------------------------------------------- */
            /* SEGMENTS */


            // Go get the saved searches from the server so we can display them
            // in the segment menu and in the manage segments modal
            $scope.GetSavedSearches = function() {

                var getSavedSearches = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]) + "/" + 'GetEntitySearchByEntityIdent');

                getSavedSearches.then(function(pl) {
                        $scope.searchstuff = pl;
                        $rootScope.SavedSearches = pl.data.EntitySearch;
                        $rootScope.SavedSearchFilters = pl.data.filters;
                        
                        // Add matching filters to SavedSearches obj
                        angular.forEach($rootScope.SavedSearchFilters, function(value, key) {
                            var TempSegment = $filter('filter')($rootScope.SavedSearches, {Ident: value.EntitySearchIdent}, true);

                            if (TempSegment) {
                                if (TempSegment[0].filters) {
                                    TempSegment[0].filters.push(value);
                                }
                                else {
                                    TempSegment[0].filters = [value];
                                }
                            }
                        });
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    });
            };


            // Creat new saved search
            $scope.showSaveSearchModal = function() {

                //(Setup) the modal and keep it in scope so we can call functions on it.
                $rootScope.SaveSearchModal = $modal.open({
                    animation: true,
                    templateUrl: 'SaveSearchModal.html',
                    scope: $rootScope,
                    size: 'md'
                });

                //Create an "Ok" function to close the modal.
                $rootScope.SaveSearchModal.ok = function(segment) {
                    $rootScope.CurrentSaveSearchName = segment.Name1;
                    $rootScope.searchCriteria.bookmark = segment.BookmarkSearch;
                    $rootScope.searchCriteria.description = segment.Desc1;
                    $rootScope.searchCriteria.category = segment.Category;

                    $scope.SaveSearch();
                    
                    $rootScope.SaveSearchModal.close();
                };
                //Create a "Cancel" function to close the modal.
                $rootScope.SaveSearchModal.cancel = function() {
                    $rootScope.CurrentSaveSearchName = '';
                    $rootScope.SaveSearchModal.close();
                };
            };


            // Save current search criteria as a segment
            $scope.SaveSearch = function(ident) {
                $rootScope.searchCriteria.name = $rootScope.CurrentSaveSearchName;

                var SegmentIdent = 0;
                if (ident) {
                    SegmentIdent = ident;
                }

                var putSaveSearch = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]) + "/" + 'AddEditEntitySearch?ident=' + SegmentIdent, $rootScope.searchCriteria);

                putSaveSearch.then(function(pl) {
                        $scope.GetSavedSearches();
                        growl.success('Segment ' + $rootScope.CurrentSaveSearchName + ' Saved!');
                    },
                    function(errorPl) {

                        growl.error($global.GetRandomErrorMessage());
                        $scope.loading = false;
                        $scope.fullScreenLoading = false;
                    });
            }


            // Update segment details
            $scope.SaveSegmentDetails = function(segment) {

                // Build new object because API needs property names 
                // to be lower case
                var EditSegment = {};
                EditSegment.name = segment.Name1;
                EditSegment.latitude = segment.Latitude;
                EditSegment.longitude = segment.Longitude;
                EditSegment.location = segment.Location;
                EditSegment.radius = segment.DistanceInMiles;
                EditSegment.keyword = segment.Keyword;
                EditSegment.bookmark = segment.BookmarkSearch;
                EditSegment.description = segment.Desc1;
                EditSegment.category = segment.Category;
                EditSegment.filters = segment.filters;

                var putSaveSearch = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]) + "/" + 'AddEditEntitySearch?ident=' + segment.Ident, EditSegment);

                putSaveSearch.then(function(pl) {
                        segment.EditMode = false;

                        $scope.SegmentsTable.reload();

                        growl.success('Segment "' + segment.Name1 + '" has been saved!');
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }


            // Manage segments
            $scope.OpenSegments = function() {

                $scope.ManageSegments = $modal.open({
                    animation: true,
                    templateUrl: 'ManageSegments.html',
                    scope: $scope,
                    size: 'lg full',
                    windowClass: 'full'
                });

                $scope.SegmentsTable = new NgTableParams({
                    sorting: { Name1: "asc" }
                }, {
                    dataset: $rootScope.SavedSearches 
                });

            }


            // Edit single segment details
            $scope.EditSegment = function(segment) {
                segment.EditMode = true;
            }


            // Apply saved search (segment)
            $scope.LoadSavedSearch = function(savedSearch) {

                if ($scope.ManageSegments) {
                    $scope.ManageSegments.close();
                }

                $scope.ClearFilters(true);
                $rootScope.CurrentSaveSearchName = savedSearch.Name1;
                $rootScope.CurrentSavedSearchIdent = savedSearch.Ident;
                if (savedSearch.Latitude !== 0 && savedSearch.Longitude !== 0) {
                    $rootScope.searchCriteria.latitude = savedSearch.Latitude;
                    $rootScope.searchCriteria.longitude = savedSearch.Longitude;
                }
                $rootScope.searchCriteria.location = savedSearch.Location;
                $rootScope.searchCriteria.radius = savedSearch.DistanceInMiles;
                $rootScope.searchCriteria.keyword = savedSearch.Keyword;

                angular.forEach($rootScope.SavedSearchFilters, function(value, key) {
                    if (value.EntitySearchIdent === $rootScope.CurrentSavedSearchIdent) {
                        //Project Specific
                        var filter;

                        if (value.EntitySearchFilterTypeIdent == 1) {
                            $rootScope.NewProjectSpecificFilter = {};
                            $rootScope.NewProjectSpecificFilter.Project = {};
                            $rootScope.NewProjectSpecificFilter.EntityProjectRequirement = {};
                            $rootScope.NewProjectSpecificFilter.EntitySearchOperator = {};

                            $rootScope.NewProjectSpecificFilter.Project.Ident = value.ReferenceIdent;
                            $rootScope.NewProjectSpecificFilter.Project.Name1 = value.ReferenceName1;
                            $rootScope.NewProjectSpecificFilter.EntityProjectRequirement.Ident = value.EntityProjectRequirementIdent;
                            $rootScope.NewProjectSpecificFilter.EntityProjectRequirement.label = value.EntityProjectRequirementName1;
                            $rootScope.NewProjectSpecificFilter.EntitySearchOperator.Ident = value.EntitySearchOperatorIdent;
                            $rootScope.NewProjectSpecificFilter.EntitySearchOperator.Name1 = value.EntitySearchOperatorName1;
                            $rootScope.NewProjectSpecificFilter.EntitySearchOperator.value = {};

                            angular.forEach(value.SearchValue.split('|'), function(innerValue, innerKey) {

                                $rootScope.NewProjectSpecificFilter.EntitySearchOperator.value[innerValue] = true;


                            });
                            $rootScope.$storage.projectSpecificFilters.push($rootScope.NewProjectSpecificFilter);


                            // organization specific
                        } else if (value.EntitySearchFilterTypeIdent == 11) {

                            // if the orgs arent load it, make sure it is here
                            if (!$rootScope.NewHierarchySpecificFilter || ($rootScope.NewHierarchySpecificFilter && !$rootScope.NewHierarchySpecificFilter.Organizations)){

                                $scope.getEntityOrganizations();

                            };

                            $rootScope.NewHierarchySpecificFilter.ToEntityIdents = value.SearchValue;
                            $rootScope.NewHierarchySpecificFilter.HierarchyTypeIdent = {};
                            $rootScope.NewHierarchySpecificFilter.HierarchyTypeIdent.Ident = value.ReferenceIdent;

                            angular.forEach(value.SearchValue.split('|'), function(innerValue, innerKey) {

                                var org = $filter('filter')($rootScope.NewHierarchySpecificFilter.Organizations, {EntityIdent: parseInt(innerValue) }, true);

                                if (org && org[0]){

                                    org[0].Checked = true;

                                };

                            });
                            $rootScope.$storage.hierarchySpecificFilters.push($rootScope.NewHierarchySpecificFilter);


                        } else {

                            angular.forEach(value.SearchValue.split('|'), function(innerValue, innerKey) {

                                var filter;
                                filter = $filter('filter')($rootScope.$storage.searchFilters, {
                                    FilterTypeIdent: value.EntitySearchFilterTypeIdent,
                                    FilterIdent: parseInt(innerValue)
                                }, true)[0];

                                if (!filter) {
                                    var searchString = '';
                                    if (value.SearchValue == 'True') {
                                        searchString = 'Yes';
                                    } else {
                                        searchString = 'No';
                                    }
                                    filter = $filter('filter')($rootScope.$storage.searchFilters, {
                                        FilterTypeIdent: value.EntitySearchFilterTypeIdent,
                                        BitValue: true,
                                        FilterName1: searchString
                                    }, true)[0];
                                }

                                if (filter) {
                                    $rootScope.changeSingleFilterState(filter);
                                }
                            });
                        }
                    }
                })
                $scope.loadFilters();
                $scope.searchResources();

                $scope.toggleSavedSearchMenu = false;
            }


            // Delete a single segment
            $scope.DeleteSearch = function(segment, index) {

                var delDeleteEntitySearch = RESTService.delete(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]), segment.Ident);

                delDeleteEntitySearch.then(function(pl) {
                        segment.EditMode = false;

                        if ($rootScope.CurrentSaveSearchName == segment.Name1) {
                            $rootScope.CurrentSaveSearchName = undefined;
                        }

                        $rootScope.SavedSearches.splice(index, 1);
                        $scope.SegmentsTable.reload();

                        growl.success('Segment "' + segment.Name1 + '" has been deleted');
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    });

                $scope.toggleSavedSearchMenu = false;

            };


            $scope.search = function() {

                $scope.loading = true;

                var addToProject = false;
                if (angular.isDefined($scope.searchCriteria.addEntityProjectIdent)) {
                    addToProject = true;
                }

                if ($scope.currentTab == 'map' && !$scope.Global) {
                    $rootScope.searchCriteria.resultsShown = 100000;
                } else if ($scope.currentTab == 'map' && $scope.Global) {
                    $rootScope.searchCriteria.resultsShown = 10000000;
                }

                if ($rootScope.searchCriteria.radius == 'Unknown') {
                    $rootScope.searchCriteria.location = '';
                    $rootScope.searchCriteria.latitude = 1.00000;
                    $rootScope.searchCriteria.longitude = 1.00000;
                }

                $rootScope.searchCriteria.SkipToIdent = 0;



                //if this is a global search, set the location to the user's zipcode and set the default radius
                if ($scope.Global && !$rootScope.searchCriteria.location && $scope.CurrentEntity) {
                    $rootScope.searchCriteria.location = $scope.CurrentEntity.Entity[0].PrimaryZip;
                    $rootScope.searchCriteria.latitude = $scope.CurrentEntity.Entity[0].Latitude;
                    $rootScope.searchCriteria.longitude = $scope.lCurrentEntity.Entity[0].Longitude;
                    $rootScope.searchCriteria.radius = $scope.defaultRadius;
                };

                if ($scope.currentTab !== 'insights' && $scope.currentTab !== 'network') {

                    var LastSecondSearchCriteria;
                    LastSecondSearchCriteria = angular.copy($rootScope.searchCriteria);
                    if (LastSecondSearchCriteria.radius == 'Unknown') {
                        LastSecondSearchCriteria.radius = 100;
                    }

                    if ($scope.Global) {
                        var postEntitySearch = RESTService.postWithTimeout(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]), LastSecondSearchCriteria, 800000);

                    } else {
                        var postEntitySearch = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]), LastSecondSearchCriteria);

                    }

                    postEntitySearch.then(function(pl, r) {


                            //Get this out of here as soon as possible
                            $scope.searchCriteria.addEntityProjectIdent = undefined;

                            /*     if ($scope.Global) {
                                     $scope.searchResults = pl.data.Results;
                                     $scope.searchResultsTotal = pl.data.Count;
                                     $scope.selectedSearchResultsTotal = $rootScope.searchResultsTotal;
                                 } else {*/
                            if (addToProject) {
                                $scope.$broadcast('ResourcesAddedToProject');
                            } else {

                                $scope.searchResults = pl.data.Entities;

                                if (pl.data && pl.data.ResultCounts && pl.data.ResultCounts[0].TotalResults !== null) {

                                    $rootScope.searchResultsTotal = pl.data.ResultCounts[0].TotalResults;
                                    $rootScope.entitySearchHistoryIdent = pl.data.ResultCounts[0].EntitySearchHistoryIdent;

                                    $scope.csvDownloadLink = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH,$rootScope.entitySearchHistoryIdent]);

                                } else {

                                    // something happened, return 0 results
                                    $rootScope.searchResultsTotal = 0;
                                    $rootScope.entitySearchHistoryIdent = 0;

                                    $scope.csvDownloadLink = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH,$rootScope.entitySearchHistoryIdent]);
                                };


                                $scope.selectedSearchResultsTotal = $rootScope.searchResultsTotal;

                            }
                            //}

                            $scope.loading = false;
                            $scope.fullScreenLoading = false;
                            $scope.$broadcast('SearchComplete');


                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                            $scope.loading = false;
                            $scope.fullScreenLoading = false;
                        });

                };
            }


            /* BEGIN functions called from the UI  */

            // Calculate map height
            $scope.mapHeight = 0;

            $scope.setHeight = function(id) {
                var windowHeight = window.innerHeight;
                var windowWidth = window.innerWidth;

                if (windowHeight >= 768 && windowWidth >= 992) {
                    var headerHeight = document.getElementById('Title').offsetHeight;
                    var contentPadding = 50;
                    var searchBarHeight = document.getElementById('SearchBar').offsetHeight;
                    var searchCountHeight = document.getElementById('SearchCount').offsetHeight;
                    var panelBorder = 2;

                    $scope.mapHeight = windowHeight - headerHeight - contentPadding - searchBarHeight - searchCountHeight - panelBorder;
                } else {
                    $scope.mapHeight = 500;
                }

                if (document.getElementById(id)){

                    document.getElementById(id).style.height = $scope.mapHeight + 'px';

                };

            }

            $scope.NavigateToAddEntity = function() {
                if ($rootScope.AddToNetworkByNPI) {
                    $state.go('site.AddEntity', {
                        NPI: $rootScope.AddToNetworkByNPI
                    });
                    $rootScope.AddToNetworkByNPI = '';
                    $rootScope.AddToNetworkByNPIModal.close();
                } else {
                    $state.go('site.AddEntity', {
                        NPI: ''
                    });
                }
            };

            $scope.showAddByNPIModal = function() {
                //(Setup) the modal and keep it in scope so we can call functions on it.
                $rootScope.AddToNetworkByNPIModal = $modal.open({
                    animation: true,
                    templateUrl: 'AddToNetworkByNPIModal.html',
                    scope: $rootScope,
                    size: 'md'

                });

                //Create an "Ok" function to close the modal.
                $rootScope.AddToNetworkByNPIModal.ok = function(npi) {

                    entityService.addEntityToNetworkByNPI(npi).then(function(pl) {
                        $rootScope.AddToNetworkByNPI = npi;
                        if (pl) {
                            $rootScope.AddToNetworkByNPI = '';
                            $rootScope.AddToNetworkByNPIModal.close();
                            growl.success('Great! This resource has been added to your network!');
                            $scope.search();
                        } else {
                            //If we didn't find it, offer to send them to the "Add Entity" screen
                            $rootScope.DidntFindNPI = true;
                        }

                    });
                };
                //Create a "Cancel" function to close the modal.
                $rootScope.AddToNetworkByNPIModal.cancel = function() {
                    $rootScope.AddToNetworkByNPI = '';
                    $rootScope.AddToNetworkByNPIModal.close();
                };
            }; // showAddByNPIModal

            $scope.init();

        }
    ])
    .directive('searchOnEnter', function() {
        return function(scope, element, attrs) {
            element.bind("keydown keypress", function(event) {
                if (event.which === 13) {
                    scope.$apply(function() {
                        scope.$eval(attrs.searchOnEnter);
                    });

                    event.preventDefault();
                }
            });
        };
    });
