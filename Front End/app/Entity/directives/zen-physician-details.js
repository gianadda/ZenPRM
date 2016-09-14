angular.module('App.zenPhysicianDetails', ['ngTable'])
.directive('zenPhysicianDetails', function() {
  return {
    restrict: 'E',
    replace: true,
    scope: {
        npi: '=',
        ident: '='
    },
    templateUrl: 'Entity/directives/zen-physician-details.html',
    controller: function ($filter, $http, $q, $scope, NgTableParams) {

        $scope.PieColors = Chart.defaults.global.colours;
        $scope.CurrDataTab = 'charts';
        $scope.Loaded2013Data = false;
        $scope.Loaded2014Data = false;
        $scope.LoadingData = true;
        $scope.ShowMessage = false;

        var init = function(){

            if ($scope.npi){

                GetOpenProviderData($scope.npi);

            } else {

                // turn off loading
                $scope.LoadingData = false;
                $scope.ShowMessage = true;

            }

        }; //initOpenData

        // Load open provider data
        var GetOpenProviderData = function(NPI) {

            // 2013 Part D Physician & Other Details
            $scope.request1 = $http.get('https://data.cms.gov/resource/5fnr-qp4c.json?npi=' + NPI);
            // 2014 Part D Physician & Other Details
            $scope.request2 = $http.get('https://data.cms.gov/resource/cng4-92f3.json?national_provider_identifier=' + NPI);

            $q.all([$scope.request1, $scope.request2]).then(function(response) {
                
                // We have 2013
                if (response[0].data.length > 0) {
                    $scope.Provider2013Raw = response[0].data;
                    $scope.Loaded2013Data = true;

                    // Clean up data for numerical sorting
                    angular.forEach($scope.Provider2013Raw, function(value, key) {
                        if ( value.line_srvc_cnt !== undefined ) {
                            value.line_srvc_cnt = parseInt(value.line_srvc_cnt);
                        }
                        if ( value.bene_unique_cnt !== undefined ) {
                            value.bene_unique_cnt = parseInt(value.bene_unique_cnt);
                        }
                        if ( value.average_medicare_allowed_amt !== undefined ) {
                            value.average_medicare_allowed_amt = parseFloat(value.average_medicare_allowed_amt);
                        }
                        if ( value.average_submitted_chrg_amt !== undefined ) {
                            value.average_submitted_chrg_amt = parseFloat(value.average_submitted_chrg_amt);
                        }
                        if ( value.average_medicare_payment_amt !== undefined ) {
                            value.average_medicare_payment_amt = parseFloat(value.average_medicare_payment_amt);
                        }
                    });
                }

                // We have 2014
                if (response[1].data.length > 0) {
                    $scope.Provider2014Raw = response[1].data;
                    $scope.Loaded2014Data = true;

                    // Clean up data for numerical sorting
                    angular.forEach($scope.Provider2014Raw, function(value, key) {
                        if ( value.number_of_services !== undefined ) {
                            value.number_of_services = parseInt(value.number_of_services);
                        }
                        if ( value.number_of_medicare_beneficiaries !== undefined ) {
                            value.number_of_medicare_beneficiaries = parseInt(value.number_of_medicare_beneficiaries);
                        }
                        if ( value.average_medicare_allowed_amount != undefined ) {
                            value.average_medicare_allowed_amount = parseFloat(value.average_medicare_allowed_amount);
                        }
                        if ( value.average_submitted_charge_amount != undefined ) {
                            value.average_submitted_charge_amount = parseFloat(value.average_submitted_charge_amount);
                        }
                        if ( value.average_medicare_payment_amount != undefined ) {
                            value.average_medicare_payment_amount = parseFloat(value.average_medicare_payment_amount);
                        }
                        if ( value.average_medicare_standardized_amount != undefined ) {
                            value.average_medicare_standardized_amount = parseFloat(value.average_medicare_standardized_amount);
                        }
                    });
                }

                // If we have either
                if ($scope.Loaded2013Data || $scope.Loaded2014Data) {
                    BuildOpenDataCharts();
                    $scope.LoadingData = false;
                }
                else {
                    $scope.LoadingData = false;
                    $scope.ShowMessage = true;
                }

             }); //$q.all

        }; // GetOpenProviderData


        var BuildOpenDataCharts = function () {

            if ($scope.Loaded2014Data) {

                $scope.Services2014Data = [];
                $scope.Services2014Labels = [];
                var other = 0;

                $scope.Services2014Filtered = $filter('orderBy')($scope.Provider2014Raw, '-number_of_services');

                angular.forEach($scope.Services2014Filtered, function(value, key) {
                    if (value.number_of_services > 0 && value.number_of_services !== undefined) {
                        // Make 10th slice a combo of all remaining data
                        if (key >= 9) {
                            $scope.Services2014Labels[9] = 'Other';
                            other = other + value.number_of_services;
                            $scope.Services2014Data[9] = other;
                        }
                        else {
                            $scope.Services2014Labels.push(value.hcpcs_code);
                            $scope.Services2014Data.push(value.number_of_services);
                        }
                    }
                });

                $scope.Services2014Popover = {
                    templateUrl: 'services-2014-popover.html',
                };

                $scope.Provider2014Table = new NgTableParams({
                    sorting: {
                        hcpcs_code: 'asc'
                    }
                }, {
                    dataset: $scope.Provider2014Raw
                });
            
            }

            if ($scope.Loaded2013Data) {

                $scope.Services2013Data = [];
                $scope.Services2013Labels = [];
                var other = 0;

                $scope.Services2013Filtered = $filter('orderBy')($scope.Provider2013Raw, '-line_srvc_cnt');

                angular.forEach($scope.Services2013Filtered, function(value, key) {
                    if (value.line_srvc_cnt > 0 && value.line_srvc_cnt !== undefined) {
                        // Make 10th slice a combo of all remaining data
                        if (key >= 9) {
                            $scope.Services2013Labels[9] = 'Other';
                            other = other + value.line_srvc_cnt;
                            $scope.Services2013Data[9] = other;
                        }
                        else {
                            $scope.Services2013Labels.push(value.hcpcs_code);
                            $scope.Services2013Data.push(value.line_srvc_cnt);
                        }
                    }
                });

                $scope.Services2013Popover = {
                    templateUrl: 'services-2013-popover.html',
                };

                $scope.Provider2013Table = new NgTableParams({
                    sorting: {
                        hcpcs_code: 'asc'
                    }
                }, {
                    dataset: $scope.Provider2013Raw
                });

            }

        }

        // Make the display value pretty
        // Modified to handle currency better
        $scope.PrettyNumber = function (val, currency) {
            if (val) {
                var PrettyNumber = $filter('number')(val);
                var str = val.toString();

                if (currency) {
                    PrettyNumber = $filter('currency')(val, '$', 2);
                }
                else if ( str.indexOf('.') > 0 ) {
                    PrettyNumber = $filter('number')(val, 2);
                }

                return PrettyNumber;
            }
        };

        init();

    }

  };

});