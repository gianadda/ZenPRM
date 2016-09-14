'use strict'

angular
    .module('App.AddEntityController', ['ngTagsInput', 'toggle-switch', 'xeditable'])
    .controller('AddEntityController', [
    '$scope',
    '$rootScope',
    '$log',
    '$filter',
    '$timeout',
    '$http',
    '$global',
    'RESTService',
    'growl',
    '$window',
    'LookupTablesService',
    'MyProfileService',
    '$stateParams',
    '$state',
    'ZenValidation',
function ($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, growl, $window, LookupTablesService, MyProfileService, $stateParams, $state, ZenValidation) {


            $scope.ZenValidation = ZenValidation;
            $scope.LookupTables = LookupTablesService;
    
            $scope.PlaceholderText = '';

            $scope.loadingProviders = false;
            $scope.EntityDelegate = {
                Ident: 0,
                FullName: ''
            };
    
            $scope.EntityToAdd = {
                EntityTypeIdent: 0,
                NPI: "",
                DBA: "",
                OrganizationName: "",
                Prefix: "",
                FirstName: "",
                MiddleName: "",
                LastName: "",
                Suffix: "",
                Title: "",
                MedicalSchool: "",
                SoleProvider: false,
                AcceptingNewPatients: false,
                GenderIdent: 0,
                Role1: "",
                Version1: "",
                PCMHStatusIdent: 0,
                PrimaryAddress1: "",
                PrimaryAddress2: "",
                PrimaryAddress3: "",
                PrimaryCity: "",
                PrimaryStateIdent: 0,
                PrimaryZip: "",
                PrimaryCounty: "",
                PrimaryPhone: "",
                PrimaryPhoneExtension: "",
                PrimaryPhone2: "",
                PrimaryPhone2Extension: "",
                PrimaryFax: "",
                PrimaryFax2: "",
                MailingAddress1: "",
                MailingAddress2: "",
                MailingAddress3: "",
                MailingCity: "",
                MailingStateIdent: 0,
                MailingZip: "",
                MailingCounty: "",
                PracticeAddress1: "",
                PracticeAddress2: "",
                PracticeAddress3: "",
                PracticeCity: "",
                PracticeStateIdent: 0,
                PracticeZip: "",
                PracticeCounty: "",
                ProfilePhoto: "",
                Website: "",
                PrescriptionLicenseNumber: "",
                PrescriptionLicenseNumberExpirationDate: "1/1/1900",
                DEANumber: "",
                DEANumberExpirationDate: "1/1/1900",
                TaxIDNumber: "",
                TaxIDNumberExpirationDate: "1/1/1900",
                MedicareUPIN: "",
                CAQHID: "",
                MeaningfulUseIdent: 0,
                EIN: "",
                Latitude: 0.0,
                Longitude: 0.0,
                Region: "",
                Active: true
            }

            if ($stateParams.NPI) {
                $scope.EntityToAdd.NPI = $stateParams.NPI;
            }

            $scope.IsValidEntityType = function ($value) {               
                if ($value != 0) {
                    return true;
                }else{
                    return false;
                };
            }
                
               
           $scope.ValidateNPI = function ($value) {
               
                if ($value === '') {
                    return true;
                }else{
                    return  ZenValidation.ValidNPI($value);
                };
            }
                
            $scope.IsPerson = function (EntityTypeIdent) {

                var selected = $filter('filter')(LookupTablesService.EntityType, {
                    Ident: EntityTypeIdent
                }, true);
                return selected.length ? selected[0].Person : false;

            }

            $scope.ValidateProviderField = function ($value) {

                if ($value !== "" && $value !== undefined) {
                    return $value.trim().length > 0;
                }
                else {
                    return false;
                }

            }

            $scope.ValidateOrganizationField = function ($value) {
                if ($value !== "" && $value !== undefined) {
                    return $value.trim().length > 0
                }
                else {
                    return false;
                }
            }
            
            $scope.IsEntityFormInvalid = function () {
                 if((!$scope.IsPerson($scope.EntityToAdd.EntityTypeIdent) && $scope.EntityToAdd.OrganizationName === undefined ) 
                     || (!$scope.IsPerson($scope.EntityToAdd.EntityTypeIdent) && !$scope.ValidateOrganizationField($scope.EntityToAdd.OrganizationName))){
                        return true;
                } else if ((!$scope.IsPerson($scope.EntityToAdd.EntityTypeIdent) && ($scope.EntityToAdd.LastName === undefined || $scope.EntityToAdd.FirstName === undefined)) 
                    || ($scope.IsPerson($scope.EntityToAdd.EntityTypeIdent) && (!$scope.ValidateProviderField($scope.EntityToAdd.LastName) || !$scope.ValidateProviderField($scope.EntityToAdd.FirstName)))) { 
                         return true;
                } else {   
                    if ($scope.EntityToAdd.EntityTypeIdent === 0) {
                         return true;
                    } else {
                         return false;
                    }
                    
                }
            }

            $scope.AddEntity = function () {
                 
                if(!$scope.IsPerson($scope.EntityToAdd.EntityTypeIdent) && !$scope.ValidateOrganizationField($scope.EntityToAdd.OrganizationName)) {
                        $scope.AddEntityForm.$invalid = true;
                } else if ($scope.IsPerson($scope.EntityToAdd.EntityTypeIdent) && !$scope.ValidateProviderField($scope.EntityToAdd.LastName)) { 
                        $scope.AddEntityForm.$invalid = true;
                } else {   
                    if ($scope.EntityToAdd.EntityTypeIdent !== 0) {

                        var selected = $filter('filter')(LookupTablesService.EntityType, {
                            Ident: $scope.EntityToAdd.EntityTypeIdent
                        }, true);
                        if (selected[0].Person) {
                            $scope.EntityToAdd.OrganizationName = '';
                        } else {
                            $scope.EntityToAdd.FirstName = '';
                            $scope.EntityToAdd.LastName = '';
                        }

                        var addProfilePost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY]), $scope.EntityToAdd);

                        addProfilePost.then(function (pl) {
                                growl.success($global.GetRandomSuccessMessage());

                                if (pl.data && pl.data.Ident) {

                                    $state.go('site.EditProfile', {
                                        ident: pl.data.Ident
                                    });
                                }
                            },
                            function (errorPl) {

                                if (errorPl.status == 403){
                                    
                                    growl.error('The NPI you have entered already exists in the system.');

                                } else {

                                    growl.error($global.GetRandomErrorMessage());

                                };

                            });
                    } 
                }
            }; //add entity

             //Ensure that there is a debounce on the typeing filter
            var timeoutPromise;
            var delayInMs = 1000;
            $scope.getProviders = function (val) {
                $scope.loadingProviders = true;
                $timeout.cancel(timeoutPromise); //does nothing, if timeout alrdy done
                timeoutPromise = $timeout(function () { //Set timeout
                    return $scope.getProvidersNow(val);
                }, delayInMs);
                return timeoutPromise;
            };

            $scope.getProvidersNow = function (val) {

                var searchCriteria = [{
                    name: "keyword",
                    value: val
                }];

                var path = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT, 0, $global.RESTControllerNames.ENTITY]);

                var getProviders = RESTService.getWithParams(path, searchCriteria);

                return getProviders.then(function (pl) {

                        $scope.loadingProviders = false;
                        return pl.data;

                    },
                    function (errorPl) {

                        $scope.loadingProviders = false;
                        return [];
                    }
                );

            }; // getProvidersNow


            $scope.setProvider = function (provider) {

                $scope.EntityToAdd.EntityDelegateIdent = $scope.EntityDelegate.Ident;

            };

    }]);