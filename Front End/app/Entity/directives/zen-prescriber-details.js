angular.module('App.zenPrescriberDetails', ['ngTable'])
.directive('zenPrescriberDetails', function() {
  return {
    restrict: 'E',
    replace: true,
    scope: {
        npi: '=',
        ident: '='
    },
    templateUrl: 'Entity/directives/zen-prescriber-details.html',
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

            // 2013 Part D Prescriber Summary
            $scope.request1 = $http.get('https://data.cms.gov/resource/hffa-2yrd.json?npi=' + NPI);
            // 2014 Part D Prescriber Summary
            $scope.request2 = $http.get('https://data.cms.gov/resource/uggq-gnqc.json?npi=' + NPI);

            $q.all([$scope.request1, $scope.request2]).then(function(response) {
                
                // We have 2013
                if (response[0].data.length > 0) {
                    $scope.Prescriber2013Raw = response[0].data;
                    $scope.Loaded2013Data = true;

                    angular.forEach($scope.Prescriber2013Raw, function(value, key) {
                        if ( value.bene_count !== undefined ) {
                            value.bene_count = parseInt(value.bene_count);
                        }
                        else {
                            value.bene_count = -1;
                        }
                        if ( value.total_claim_count !== undefined ) {
                            value.total_claim_count = parseInt(value.total_claim_count);
                        }
                        if ( value.total_day_supply !== undefined ) {
                            value.total_day_supply = parseInt(value.total_day_supply);
                        }
                        if ( value.total_drug_cost !== undefined ) {
                            value.total_drug_cost = parseFloat(value.total_drug_cost);
                        }
                    });
                }
                
                // We have 2014
                if (response[1].data.length > 0) {
                    $scope.Prescriber2014Raw = response[1].data;
                    $scope.Loaded2014Data = true;

                    angular.forEach($scope.Prescriber2014Raw, function(value, key) {
                        if ( value.bene_count !== undefined ) {
                            value.bene_count = parseInt(value.bene_count);
                        }
                        else {
                            value.bene_count = -1;
                        }
                        if ( value.total_claim_count !== undefined ) {
                            value.total_claim_count = parseInt(value.total_claim_count);
                        }
                        if ( value.total_day_supply !== undefined ) {
                            value.total_day_supply = parseInt(value.total_day_supply);
                        }
                        if ( value.total_drug_cost !== undefined ) {
                            value.total_drug_cost = parseFloat(value.total_drug_cost);
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

                $scope.Drugs2014Data = [];
                $scope.Drugs2014Labels = [];
                var other = 0;

                $scope.Drugs2014Filtered = $filter('orderBy')($scope.Prescriber2014Raw, '-total_claim_count');

                angular.forEach($scope.Drugs2014Filtered, function(value, key) {
                    if (value.total_claim_count > 0 && value.total_claim_count !== undefined) {
                        // Make 10th slice a combo of all remaining data
                        if (key >= 9) {
                            $scope.Drugs2014Labels[9] = 'Other';
                            other = other + parseInt(value.total_claim_count);
                            $scope.Drugs2014Data[9] = other;
                        }
                        else {
                            $scope.Drugs2014Labels.push(value.drug_name);
                            $scope.Drugs2014Data.push(value.total_claim_count);
                        }
                    }
                });

                $scope.Drugs2014Popover = {
                    templateUrl: 'drugs-2014-popover.html',
                };

                $scope.Prescriber2014Table = new NgTableParams({
                    sorting: {
                        drug_name: 'asc'
                    }
                }, {
                    dataset: $scope.Prescriber2014Raw
                });
            
            }

            if ($scope.Loaded2013Data) {

                $scope.Drugs2013Data = [];
                $scope.Drugs2013Labels = [];
                var other = 0;

                $scope.Drugs2013Filtered = $filter('orderBy')($scope.Prescriber2013Raw, '-total_claim_count');

                angular.forEach($scope.Drugs2013Filtered, function(value, key) {
                    if (value.total_claim_count > 0 && value.total_claim_count !== undefined) {
                        // Make 10th slice a combo of all remaining data
                        if (key >= 9) {
                            $scope.Drugs2013Labels[9] = 'Other';
                            other = other + parseInt(value.total_claim_count);
                            $scope.Drugs2013Data[9] = other;
                        }
                        else {
                            $scope.Drugs2013Labels.push(value.drug_name);
                            $scope.Drugs2013Data.push(value.total_claim_count);
                        }
                    }
                });

                $scope.Drugs2013Popover = {
                    templateUrl: 'drugs-2013-popover.html',
                };

                $scope.Prescriber2013Table = new NgTableParams({
                    sorting: {
                        drug_name: 'asc'
                    }
                }, {
                    dataset: $scope.Prescriber2013Raw
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