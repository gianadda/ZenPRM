angular.module('App.zenPrescriberSummary', [])
.directive('zenPrescriberSummary', function() {
  return {
    restrict: 'E',
    replace: true,
    scope: {
        npi: '=',
        ident: '='
    },
    templateUrl: 'Entity/directives/zen-prescriber-summary.html',
    controller: function ($filter, $http, $q, $scope) {

        $scope.PieColors = Chart.defaults.global.colours;
        $scope.CurrDataTab = 'charts';
        $scope.Loaded2013Data = false;
        $scope.Loaded2014Data = false;
        $scope.LoadingData = true;
        $scope.ShowMessage = false;
        $scope.CompareData = false;

        $scope.initOpenData = function(){

            if ($scope.npi){
                $scope.GetOpenProviderData($scope.npi);
            }
            else {
                $scope.LoadingData = false;
                $scope.ShowMessage = true;
            }

        }; //initOpenData

        // Load open provider data
        $scope.GetOpenProviderData = function(NPI) {

            // 2013 Part D Prescriber Summary
            $scope.request1 = $http.get('https://data.cms.gov/resource/wynz-2bqg.json?national_provider_identifier=' + NPI);
            // 2014 Part D Prescriber Summary
            $scope.request2 = $http.get('https://data.cms.gov/resource/5i8t-h864.json?npi=' + NPI);

            $q.all([$scope.request1, $scope.request2]).then(function(response) {
                
                // We have 2013
                if (response[0].data.length > 0) {
                    var RawData2013 = response[0].data[0];
                    $scope.Loaded2013Data = true;

                    // Convert data into nice format
                    $scope.CleanData2013 = {
                        Summary: [
                            {
                                Name: 'All Beneficiaries',
                                Data: [
                                    {
                                        Name: 'Beneficiary Count',
                                        Value: RawData2013.bene_count
                                    },
                                    {
                                        Name: 'Total Claim Count',
                                        Value: RawData2013.total_claim_count
                                    },
                                    {
                                        Name: 'Total Drug Cost',
                                        Value: RawData2013.total_drug_cost,
                                        Money: true
                                    },
                                    {
                                        Name: 'Total Day Supply',
                                        Value: RawData2013.total_day_supply
                                    }
                                ]
                            },
                            {
                                Name: 'Benficiaries Aged 65+',
                                Data: [
                                    {
                                        Name: 'Beneficiary Count',
                                        Value: RawData2013.bene_count_ge65
                                    },
                                    {
                                        Name: 'Total Claim Count',
                                        Value: RawData2013.total_claim_count_ge65
                                    },
                                    {
                                        Name: 'Total Drug Cost',
                                        Value: RawData2013.total_drug_cost_ge65,
                                        Money: true
                                    },
                                    {
                                        Name: 'Total Day Supply',
                                        Value: RawData2013.total_day_supply_ge65
                                    }
                                ]
                            }
                        ],
                        Brands: [
                            {
                                Name: 'Claims by Type',
                                Data: [
                                    {
                                        Name: 'Brand Claim Count', 
                                        Value: RawData2013.brand_claim_count
                                    },
                                    {
                                        Name: 'Generic Claim Count',
                                        Value: RawData2013.generic_claim_count
                                    },
                                    {
                                        Name: 'Other Claim Count',
                                        Value: RawData2013.other_claim_count
                                    }
                                ]
                            },
                            {
                                Name: 'Drug Costs by Type',
                                Data: [
                                    {
                                        Name: 'Brand Drug Cost',
                                        Value: RawData2013.brand_drug_cost,
                                        Money: true
                                    },
                                    {
                                        Name: 'Generic Drug Cost',
                                        Value: RawData2013.generic_drug_cost,
                                        Money: true
                                    },
                                    {
                                        Name: 'Other Drug Cost',
                                        Value: RawData2013.other_drug_cost,
                                        Money: true
                                    }
                                ]
                            }
                        ],
                        Coverages: [
                            {
                                Name: 'Medicare Advantage Prescription Drug Plans',
                                Data: [
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2013.mapd_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2013.mapd_drug_cost,
                                        Money: true
                                    }
                                ]
                            },
                            {
                                Name: 'Standalone Prescription Drug Plans',
                                Data: [
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2013.pdp_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2013.pdp_drug_cost,
                                        Money: true
                                    }
                                ]
                            },
                            {
                                Name: 'Low Income Subsidy',
                                Data: [
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2013.lis_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2013.lis_drug_cost,
                                        Money: true
                                    }
                                ]
                            },
                            {
                                Name: 'Non Low Income Subsidy',
                                Data: [
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2013.non_lis_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2013.non_lis_drug_cost,
                                        Money: true
                                    }
                                ]
                            }
                        ]
                    };

                }

                // We have 2014
                if (response[1].data.length > 0) {
                    var RawData2014 = response[1].data[0];
                    $scope.Loaded2014Data = true;

                    // Convert data into nice format
                    $scope.CleanData2014 = {
                        Summary: [
                            {
                                Name: 'All Beneficiaries',
                                Data: [
                                    {
                                        Name: 'Beneficiary Count',
                                        Value: RawData2014.bene_count
                                    },
                                    {
                                        Name: 'Total Claim Count',
                                        Value: RawData2014.total_claim_count
                                    },
                                    {
                                        Name: 'Total Drug Cost',
                                        Value: RawData2014.total_drug_cost,
                                        Money: true
                                    },
                                    {
                                        Name: 'Total Day Supply',
                                        Value: RawData2014.total_day_supply
                                    }
                                ]
                            },
                            {
                                Name: 'Benficiaries Aged 65+',
                                Data: [
                                    {
                                        Name: 'Beneficiary Count',
                                        Value: RawData2014.bene_count_ge65
                                    },
                                    {
                                        Name: 'Total Claim Count',
                                        Value: RawData2014.total_claim_count_ge65
                                    },
                                    {
                                        Name: 'Total Drug Cost',
                                        Value: RawData2014.total_drug_cost_ge65,
                                        Money: true
                                    },
                                    {
                                        Name: 'Total Day Supply',
                                        Value: RawData2014.total_day_supply_ge65
                                    }
                                ]
                            },
                            {
                                Name: 'High Risk Medicine Beneficiaries Aged 65+',
                                Type: 'Summary',
                                Data: [
                                    {
                                        Name: 'Beneficiary Count',
                                        Value: RawData2014.hrm_bene_count_ge65
                                    },
                                    {
                                        Name: 'Total Claim Count',
                                        Value: RawData2014.hrm_claim_count_ge65
                                    },
                                    {
                                        Name: 'Total Drug Cost',
                                        Value: RawData2014.hrm_drug_cost_ge65,
                                        Money: true
                                    }
                                ]
                            }
                        ],
                        Brands: [
                            {
                                Name: 'Claims by Type',
                                Data: [
                                    {
                                        Name: 'Brand Claim Count', 
                                        Value: RawData2014.brand_claim_count
                                    },
                                    {
                                        Name: 'Generic Claim Count',
                                        Value: RawData2014.generic_claim_count
                                    },
                                    {
                                        Name: 'Other Claim Count',
                                        Value: RawData2014.other_claim_count
                                    }
                                ]
                            },
                            {
                                Name: 'Drug Costs by Type',
                                Data: [
                                    {
                                        Name: 'Brand Drug Cost',
                                        Value: RawData2014.brand_drug_cost,
                                        Money: true
                                    },
                                    {
                                        Name: 'Generic Drug Cost',
                                        Value: RawData2014.generic_drug_cost,
                                        Money: true
                                    },
                                    {
                                        Name: 'Other Drug Cost',
                                        Value: RawData2014.other_drug_cost,
                                        Money: true
                                    }
                                ]
                            }
                        ],
                        Coverages: [
                            {
                                Name: 'Medicare Advantage Prescription Drug Plans',
                                Data: [
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2014.mapd_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2014.mapd_drug_cost,
                                        Money: true
                                    }
                                ]
                            },
                            {
                                Name: 'Standalone Prescription Drug Plans',
                                Data: [
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2014.pdp_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2014.pdp_drug_cost,
                                        Money: true
                                    }
                                ]
                            },
                            {
                                Name: 'Low Income Subsidy',
                                Data: [
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2014.lis_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2014.lis_drug_cost,
                                        Money: true
                                    }
                                ]
                            },
                            {
                                Name: 'Non Low Income Subsidy',
                                Data: [
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2014.non_lis_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2014.non_lis_drug_cost,
                                        Money: true
                                    }
                                ]
                            }
                        ],
                        DrugTypes: [
                            {
                                Name: 'Opioid',
                                Data: [
                                    {
                                        Name: 'Beneficiary Count',
                                        Value: RawData2014.opioid_bene_count
                                    },
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2014.opioid_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2014.opioid_drug_cost,
                                        Money: true
                                    },
                                    {
                                        Name: 'Day Supply',
                                        Value: RawData2014.opioid_day_supply
                                    }
                                ]
                            },
                            {
                                Name: 'Antibiotic',
                                Data: [
                                    {
                                        Name: 'Beneficiary Count',
                                        Value: RawData2014.antibiotic_bene_count
                                    },
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2014.antibiotic_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2014.antibiotic_drug_cost,
                                        Money: true
                                    }
                                ]
                            },
                            {
                                Name: 'Antipsychotic',
                                Data: [
                                    {
                                        Name: 'Beneficiary Count',
                                        Value: RawData2014.anti_psych_bene_count
                                    },
                                    {
                                        Name: 'Claim Count',
                                        Value: RawData2014.anti_psych_claim_count
                                    },
                                    {
                                        Name: 'Drug Cost',
                                        Value: RawData2014.anti_psych_drug_cost,
                                        Money: true
                                    }
                                ]
                            }
                        ]
                    };

                }

                // If we have either
                if ($scope.Loaded2013Data || $scope.Loaded2014Data) {
                    $scope.BuildCharts();
                    $scope.LoadingData = false;
                }
                else {
                    $scope.LoadingData = false;
                    $scope.ShowMessage = true;
                }

             }); //$q.all

        }; // GetOpenProviderData


        // Build cool data visualizations
        $scope.BuildCharts = function () {

            // Establish primary dataset
            if ($scope.Loaded2014Data) {
                $scope.PrimaryData = $scope.CleanData2014;
                $scope.PrimaryDataKey = '2014';

                // Do we also have 2013?
                if ($scope.Loaded2013Data) {
                    $scope.SecondaryData = $scope.CleanData2013;
                    $scope.CompareData = true;
                }
            }
            else {
                $scope.PrimaryData = $scope.CleanData2013;
                $scope.PrimaryDataKey = '2013';
            }

            // ### Brand Count Pie Chart ### //
            
            $scope.BrandCountChartLabels = [];
            $scope.BrandCountChartData = [];
            $scope.ShowBrandCountChart = false;
            var BrandCountTally = 0;

            angular.forEach($scope.PrimaryData.Brands[0].Data, function(value, key) {
                if (value.Value !== undefined) {
                    $scope.BrandCountChartLabels.push(value.Name);
                    $scope.BrandCountChartData.push(value.Value);
                    BrandCountTally = BrandCountTally + parseInt(value.Value);
                }
            });

            if (BrandCountTally > 0) {
                $scope.ShowBrandCountChart = true;
            }

            $scope.BrandCountPopover = {
                templateUrl: 'brand-count-popover.html',
            };

            // ### Brand Cost Pie Chart ### //
            
            $scope.BrandCostChartLabels = [];
            $scope.BrandCostChartData = [];
            $scope.ShowBrandCostChart = false;
            var BrandCostTally = 0;

            angular.forEach($scope.PrimaryData.Brands[1].Data, function(value, key) {
                if (value.Value !== undefined) {
                    $scope.BrandCostChartLabels.push(value.Name);
                    $scope.BrandCostChartData.push(value.Value);
                    BrandCostTally = BrandCostTally + parseInt(value.Value);
                }
            });

            if (BrandCostTally > 0) {
                $scope.ShowBrandCostChart = true;
            }

            $scope.BrandCostPopover = {
                templateUrl: 'brand-cost-popover.html',
            };

        }; //BuildCharts


        // Compare two data points (primary vs secondary)
        $scope.CompareDataPoints = function (val1, val2) {
            if (val1 && val2) {
                var className = 'fa-minus-circle';

                val1 = parseFloat(val1);
                val2 = parseFloat(val2);

                if (val1 > val2) {
                    className = "fa-arrow-up";
                }
                if (val1 < val2) {
                    className = "fa-arrow-down";
                }

                return className;
            }
        }; //CompareDataPoints


        // Make the display value pretty
        $scope.PrettyNumber = function (val) {
            if (val) {
                var PrettyNumber = $filter('number')(val);
                var str = val.toString();
                var numChars = str.length;
                var numDecimals = 0;

                if ( str.indexOf('.') > 0 ) {
                    numDecimals = numChars - str.indexOf('.');
                    
                    if ( numDecimals > 3 ) {
                        PrettyNumber = $filter('number')(val, 2);
                    }
                }

                return PrettyNumber;
            }
        };

        $scope.initOpenData();

    }

  };

});