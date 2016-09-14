angular.module('App.zenPhysicianSummary', [])
.directive('zenPhysicianSummary', function() {
  return {
    restrict: 'E',
    replace: true,
    scope: {
        npi: '=',
        ident: '='
    },
    templateUrl: 'Entity/directives/zen-physician-summary.html',
    controller: function ($filter, $http, $q, $scope) {

        $scope.PieColors = Chart.defaults.global.colours;
        $scope.CurrDataTab = 'charts';
        $scope.Loaded2013Data = false;
        $scope.Loaded2014Data = false;
        $scope.LoadingData = true;
        $scope.ShowMessage = false;
        $scope.CompareData = false;

        var init = function(){

            if ($scope.npi){
                GetOpenProviderData($scope.npi);
            }
            else {
                // turn off loading
                $scope.LoadingData = false;
                $scope.ShowMessage = true;
            }

        }; //initOpenData

        // Load open provider data
        var GetOpenProviderData = function(NPI) {

            // 2013
            var request1 = $http.get('https://data.cms.gov/resource/6wsi-uvti.json?npi=' + NPI);
            // 2014
            var request2 = $http.get('https://data.cms.gov/resource/sdqm-3ic8.json?national_provider_identifier=' + NPI);

            $q.all([request1, request2]).then(function(response) {
                
                // We only have 2013
                if (response[0].data.length > 0) {
                    var RawData2013 = response[0].data[0];
                    $scope.Loaded2013Data = true;

                    // Convert data into nice format
                    $scope.CleanData2013 = {
                        Summary: [
                            {
                                Name: 'At a Glance',
                                Data: [
                                    {
                                        Name: 'Number of Unique Beneficiaries',
                                        Value: RawData2013.number_of_unique_beneficiaries
                                    },
                                    {
                                        Name: 'Average Age of Beneficiaries',
                                        Value: RawData2013.average_age_of_beneficiaries
                                    },
                                    {
                                        Name: 'Number of HCPCS',
                                        Value: RawData2013.number_of_hcpcs
                                    },
                                    {
                                        Name: 'Average HCC Risk Score of Beneficiaries',
                                        Value: RawData2013.average_hcc_risk_score_of_benefi
                                    }
                                ]
                            }
                        ],
                        Demographics: [
                            {
                                Name: 'Gender',
                                Data: [
                                    {
                                        Name: "Female", 
                                        Value: RawData2013.number_of_female_beneficiaries, 
                                    },
                                    {
                                        Name: "Male",
                                        Value: RawData2013.number_of_male_beneficiaries
                                    }
                                ]
                            },
                            {
                                Name: 'Race',
                                Data: [
                                    {
                                        Name: 'Non-Hispanic White', 
                                        Value: RawData2013.number_of_non_hispanic_white_ben
                                    },
                                    {
                                        Name: 'Black or African American',
                                        Value: RawData2013.number_of_black_or_african_ameri
                                    },
                                    {
                                        Name: 'Asian Pacific Islander',
                                        Value: RawData2013.number_of_asian_pacific_islander
                                    },
                                    {
                                        Name: 'Hispanic',
                                        Value: RawData2013.number_of_hispanic_beneficiaries
                                    },
                                    {
                                        Name: 'American Indian/Alaska Native',
                                        Value: RawData2013.number_of_american_indian_alaska
                                    },
                                    {
                                        Name: 'Race Not Elsewhere Classified',
                                        Value: RawData2013.number_of_beneficiaries_with_rac
                                    }
                                ],
                            },
                            {
                                Name: 'Age',
                                Data: [
                                    {
                                        Name: '< 65', 
                                        Value: RawData2013.number_of_beneficiaries_age_less
                                    },
                                    {
                                        Name: '65-74',
                                        Value: RawData2013.number_of_beneficiaries_age_65_t
                                    },
                                    {
                                        Name: '75-84',
                                        Value: RawData2013.number_of_beneficiaries_age_75_t
                                    },
                                    {
                                        Name: '> 84',
                                        Value: RawData2013.number_of_beneficiaries_age_grea
                                    }
                                ]
                            }
                        ],
                        Eligibility: [
                            {
                                Name: 'Dual Eligibility',
                                Data: [
                                    {
                                        Name: 'Number of Beneficiaries With Medicare Only Entitlement',
                                        Value: RawData2013.number_of_beneficiaries_with_med
                                    },
                                    {
                                        Name: 'Number of Beneficiaries With Medicare & Medicaid Entitlement',
                                        Value: RawData2013.number_of_beneficiaries_wit_0001
                                    }
                                ]
                            }
                        ],
                        Conditions: [
                            {
                                Name: 'Beneficiary Medical Conditions',
                                Data: [
                                    {
                                        Name: 'Alzheimer\'s Disease or Dementia',
                                        Value: RawData2013.percent_of_beneficiaries_ide
                                    },
                                    {
                                        Name: 'Asthma',
                                        Value: RawData2013.percent_of_beneficiarie_0001
                                    },
                                    {
                                        Name: 'Atrial Fibrillation',
                                        Value: RawData2013.percent_of_beneficiarie_0002
                                    },
                                    {
                                        Name: 'Cancer',
                                        Value: RawData2013.percent_of_beneficiarie_0003
                                    },
                                    {
                                        Name: 'Chronic Kidney Disease',
                                        Value: RawData2013.percent_of_beneficiarie_0004
                                    },
                                    {
                                        Name: 'Chronic Obstructive Pulmonary Disease',
                                        Value: RawData2013.percent_of_beneficiarie_0005
                                    },
                                    {
                                        Name: 'Depression',
                                        Value: RawData2013.percent_of_beneficiarie_0006
                                    },
                                    {
                                        Name: 'Diabetes',
                                        Value: RawData2013.percent_of_beneficiarie_0007
                                    },
                                    {
                                        Name: 'Heart Failure',
                                        Value: RawData2013.percent_of_beneficiarie_0008
                                    },
                                    {
                                        Name: 'Hyperlipidemia',
                                        Value: RawData2013.percent_of_beneficiarie_0009
                                    },
                                    {
                                        Name: 'Hypertension',
                                        Value: RawData2013.percent_of_beneficiarie_0010
                                    },
                                    {
                                        Name: 'Ischemic Heart Disease',
                                        Value: RawData2013.percent_of_beneficiarie_0011
                                    },
                                    {
                                        Name: 'Osteoporosis',
                                        Value: RawData2013.percent_of_beneficiarie_0012
                                    },
                                    {
                                        Name: 'Rheumatoid Arthritis / Osteoarthritis',
                                        Value: RawData2013.percent_of_beneficiarie_0013
                                    },
                                    {
                                        Name: 'Schizophrenia / Other Psychotic Disorders',
                                        Value: RawData2013.percent_of_beneficiarie_0014
                                    },
                                    {
                                        Name: 'Stroke',
                                        Value: RawData2013.percent_of_beneficiarie_0015
                                    }
                                ]
                            }
                        ],
                        Services: [
                            {
                                Name: 'Service Summary',
                                Data: [
                                    {
                                        Name: 'Number of Services',
                                        Value: RawData2013.number_of_services,
                                        Show: true
                                    },
                                    {
                                        Name: 'Drug Supress Indicator',
                                        Value: RawData2013.drug_suppress_indicator
                                    },
                                    {
                                        Name: 'Number of HCPCS Associated With Drug Services',
                                        Value: RawData2013.number_of_hcpcs_associated_with
                                    },
                                    {
                                        Name: 'Number of Drug Services',
                                        Value: RawData2013.number_of_drug_services,
                                        Show: true
                                    },
                                    {
                                        Name: 'Number of Unique Beneficiaries With Drug Services',
                                        Value: RawData2013.number_of_unique_beneficiaries_w
                                    },
                                    {
                                        Name: 'Medical Suppress Indicator',
                                        Value: RawData2013.medical_suppress_indicator
                                    },
                                    {
                                        Name: 'Number of HCPCS Associated With Medical Services',
                                        Value: RawData2013.number_of_hcpcs_associated_with_medical_services
                                    },
                                    {
                                        Name: 'Number of Medical Services',
                                        Value: RawData2013.number_of_medical_services,
                                        Show: true
                                    },
                                    {
                                        Name: 'Number of Unique Beneficiaries With Medical Services',
                                        Value: RawData2013.number_of_unique_beneficiaries_with_medical_services,
                                        Show: true
                                    }
                                ]
                            }
                        ],
                        Financial: [
                            {
                                Name: 'Financial Summary',
                                Data: [
                                    {
                                        TypeIdent: 1,
                                        Name: 'Total Submitted Charges',
                                        Value: RawData2013.total_submitted_charges,
                                        Show: true,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 1,
                                        Name: 'Total Medicare Allowed Amount',
                                        Value: RawData2013.total_medicare_allowed_amount,
                                        Show: true,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 1,
                                        Name: 'Total Medicare Payment Amount',
                                        Value: RawData2013.total_medicare_payment_amount,
                                        Show: true,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 2,
                                        Name: 'Total Drug Submitted Charges',
                                        Value: RawData2013.total_drug_submitted_charges,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 2,
                                        Name: 'Total Drug Medicare Allowed Amount',
                                        Value: RawData2013.total_drug_medicare_allowed_amou,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 2,
                                        Name: 'Total Drug Medicare Payment Amount',
                                        Value: RawData2013.total_drug_medicare_payment_amou,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 3,
                                        Name: 'Total Medical Submitted Charges',
                                        Value: RawData2013.total_medical_submitted_charges,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 3,
                                        Name: 'Total Medical Medicare Allowed Amount',
                                        Value: RawData2013.total_medical_medicare_allowed_amount,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 3,
                                        Name: 'Total Medical Medicare Payment Amount',
                                        Value: RawData2013.total_medical_medicare_payment_amount,
                                        Money: true
                                    }
                                ]
                            }
                        ]
                    };
                
                }
                
                // We only have 2014
                if (response[1].data.length > 0) {
                    $scope.Loaded2014Data = true;
                    var RawData2014 = response[1].data[0];

                    // Convert data into nice format
                    $scope.CleanData2014 = {
                        Summary: [
                            {
                                Name: 'At a Glance',
                                Data: [
                                    {
                                        Name: 'Number of Unique Beneficiaries',
                                        Value: RawData2014.number_of_medicare_beneficiaries
                                    },
                                    {
                                        Name: 'Average Age of Beneficiaries',
                                        Value: RawData2014.average_age_of_beneficiaries
                                    },
                                    {
                                        Name: 'Number of HCPCS',
                                        Value: RawData2014.number_of_hcpcs
                                    },
                                    {
                                        Name: 'Average HCC Risk Score of Beneficiaries',
                                        Value: RawData2014.average_hcc_risk_score_of_beneficiaries
                                    }
                                ]
                            }
                        ],
                        Demographics: [
                            {
                                Name: 'Gender',
                                Data: [
                                    {
                                        Name: "Female", 
                                        Value: RawData2014.number_of_female_beneficiaries, 
                                    },
                                    {
                                        Name: "Male",
                                        Value: RawData2014.number_of_male_beneficiaries
                                    }
                                ]
                            },
                            {
                                Name: 'Race',
                                Data: [
                                    {
                                        Name: 'Non-Hispanic White', 
                                        Value: RawData2014.number_of_non_hispanic_white_beneficiaries
                                    },
                                    {
                                        Name: 'Black or African American',
                                        Value: RawData2014.number_of_black_or_african_american_beneficiaries
                                    },
                                    {
                                        Name: 'Asian Pacific Islander',
                                        Value: RawData2014.number_of_asian_pacific_islander_beneficiaries
                                    },
                                    {
                                        Name: 'Hispanic',
                                        Value: RawData2014.number_of_hispanic_beneficiaries
                                    },
                                    {
                                        Name: 'American Indian/Alaska Native',
                                        Value: RawData2014.number_of_american_indian_alaska_native_beneficiaries
                                    },
                                    {
                                        Name: 'Race Not Elsewhere Classified',
                                        Value: RawData2014.number_of_beneficiaries_with_race_not_elsewhere_classified
                                    }
                                ]
                            },
                            {
                                Name: 'Age',
                                Data: [
                                    {
                                        Name: '< 65', 
                                        Value: RawData2014.number_of_beneficiaries_age_less_65
                                    },
                                    {
                                        Name: '65-74',
                                        Value: RawData2014.number_of_beneficiaries_age_65_to_74
                                    },
                                    {
                                        Name: '75-84',
                                        Value: RawData2014.number_of_beneficiaries_age_75_to_84
                                    },
                                    {
                                        Name: '> 84',
                                        Value: RawData2014.number_of_beneficiaries_age_greater_84
                                    }
                                ]
                            }
                        ],
                        Eligibility: [
                            {
                                Name: 'Dual Eligibility',
                                Data: [
                                    {
                                        Name: 'Number of Beneficiaries With Medicare Only Entitlement',
                                        Value: RawData2014.number_of_beneficiaries_with_medicare_only_entitlement
                                    },
                                    {
                                        Name: 'Number of Beneficiaries With Medicare & Medicaid Entitlement',
                                        Value: RawData2014.number_of_beneficiaries_with_medicare_medicaid_entitlement
                                    }
                                ]
                            }
                        ],
                        Conditions: [
                            {
                                Name: 'Beneficiary Medical Conditions',
                                Data: [
                                    {
                                        Name: 'Alzheimer\'s Disease or Dementia',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_alzheimer_s_disease_or_dementia
                                    },
                                    {
                                        Name: 'Asthma',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_asthma
                                    },
                                    {
                                        Name: 'Atrial Fibrillation',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_atrial_fibrillation
                                    },
                                    {
                                        Name: 'Cancer',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_cancer
                                    },
                                    {
                                        Name: 'Chronic Kidney Disease',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_chronic_kidney_disease
                                    },
                                    {
                                        Name: 'Chronic Obstructive Pulmonary Disease',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_chronic_obstructive_pulmonary_disease
                                    },
                                    {
                                        Name: 'Depression',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_depression
                                    },
                                    {
                                        Name: 'Diabetes',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_diabetes
                                    },
                                    {
                                        Name: 'Heart Failure',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_heart_failure
                                    },
                                    {
                                        Name: 'Hyperlipidemia',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_hyperlipidemia
                                    },
                                    {
                                        Name: 'Hypertension',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_hypertension
                                    },
                                    {
                                        Name: 'Ischemic Heart Disease',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_ischemic_heart_disease
                                    },
                                    {
                                        Name: 'Osteoporosis',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_osteoporosis
                                    },
                                    {
                                        Name: 'Rheumatoid Arthritis / Osteoarthritis',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_rheumatoid_arthritis_osteoarthritis
                                    },
                                    {
                                        Name: 'Schizophrenia / Other Psychotic Disorders',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_schizophrenia_other_psychotic_disorders
                                    },
                                    {
                                        Name: 'Stroke',
                                        Value: RawData2014.percent_of_beneficiaries_identified_with_stroke
                                    }
                                ]
                            }
                        ],
                        Services: [
                            {
                                Name: 'Service Summary',
                                Data: [
                                    {
                                        Name: 'Number of Services',
                                        Value: RawData2014.number_of_services,
                                        Show: true
                                    },
                                    {
                                        Name: 'Number of HCPCS Associated With Drug Services',
                                        Value: RawData2014.number_of_hcpcs_associated_with_drug_services
                                    },
                                    {
                                        Name: 'Number of Drug Services',
                                        Value: RawData2014.number_of_drug_services,
                                        Show: true
                                    },
                                    {
                                        Name: 'Number of Unique Beneficiaries With Drug Services',
                                        Value: RawData2014.number_of_medicare_beneficiaries_with_drug_services
                                    },
                                    {
                                        Name: 'Number of HCPCS Associated With Medical Services',
                                        Value: RawData2014.number_of_hcpcs_associated_with_medical_services
                                    },
                                    {
                                        Name: 'Number of Medical Services',
                                        Value: RawData2014.number_of_medical_services,
                                        Show: true
                                    },
                                    {
                                        Name: 'Number of Unique Beneficiaries With Medical Services',
                                        Value: RawData2014.number_of_medicare_beneficiaries_with_medical_services,
                                        Show: true
                                    }
                                ]
                            }
                        ],
                        Financial: [
                            {
                                Name: 'Financial Summary',
                                Data: [
                                    {
                                        TypeIdent: 1,
                                        Name: 'Total Submitted Charges',
                                        Value: RawData2014.total_submitted_charge_amount,
                                        Show: true,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 1,
                                        Name: 'Total Medicare Allowed Amount',
                                        Value: RawData2014.total_medicare_allowed_amount,
                                        Show: true,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 1,
                                        Name: 'Total Medicare Payment Amount',
                                        Value: RawData2014.total_medicare_payment_amount,
                                        Show: true,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 1,
                                        Name: 'Total Medicare Standardized Payment Amount',
                                        Value: RawData2014.total_medicare_standardized_payment_amount,
                                        Show: true,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 2,
                                        Name: 'Total Drug Submitted Charges',
                                        Value: RawData2014.total_drug_submitted_charge_amount,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 2,
                                        Name: 'Total Drug Medicare Allowed Amount',
                                        Value: RawData2014.total_drug_medicare_allowed_amount,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 2,
                                        Name: 'Total Drug Medicare Payment Amount',
                                        Value: RawData2014.total_drug_medicare_payment_amount,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 2,
                                        Name: 'Total Drug Medicare Standardized Payment Amount',
                                        Value: RawData2014.total_drug_medicare_standardized_payment_amount,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 3,
                                        Name: 'Total Medical Submitted Charges',
                                        Value: RawData2014.total_medical_submitted_charge_amount,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 3,
                                        Name: 'Total Medical Medicare Allowed Amount',
                                        Value: RawData2014.total_medical_medicare_allowed_amount,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 3,
                                        Name: 'Total Medical Medicare Payment Amount',
                                        Value: RawData2014.total_medical_medicare_payment_amount,
                                        Money: true
                                    },
                                    {
                                        TypeIdent: 3,
                                        Name: 'Total Medical Medicare Standardized Payment Amount',
                                        Value: RawData2014.total_medical_medicare_standardized_payment_amount,
                                        Money: true
                                    }
                                ]
                            }
                        ]
                    };
                
                }

                // If we have either
                if ($scope.Loaded2013Data || $scope.Loaded2014Data) {
                    BuildCharts();
                    $scope.LoadingData = false;
                }
                else {
                    $scope.LoadingData = false;
                    $scope.ShowMessage = true;
                }

             }); //$q.all

        }; // GetOpenProviderData


        // Build cool data visualizations
        var BuildCharts = function () {

            // Let's determine which dataset is our primary
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

            var TotalBeneficiaries = $scope.PrimaryData.Summary[0].Data[0].Value;

            // ### Beneficiary Gender Pie Chart ### //
            
            $scope.GenderChartLabels = [];
            $scope.GenderChartData = [];
            $scope.ShowGenderChart = false;
            var GenderTally = 0;

            angular.forEach($scope.PrimaryData.Demographics[0].Data, function(value, key) {
                if (value.Value !== undefined) {
                    $scope.GenderChartLabels.push(value.Name);
                    $scope.GenderChartData.push(value.Value);
                    GenderTally = GenderTally + parseInt(value.Value);
                }
            });

            // Don't show chart if all data points == 0
            if (GenderTally > 0) {
                $scope.ShowGenderChart = true;

                if (GenderTally < TotalBeneficiaries) {
                    $scope.GenderChartLabels.push('Not Reported');
                    $scope.GenderChartData.push(TotalBeneficiaries - GenderTally);
                }
            }

            $scope.GenderPopover = {
                templateUrl: 'gender-popover.html',
            };

            // ### Beneficiary Race Pie Chart ### //

            $scope.RaceChartLabels = [];
            $scope.RaceChartData = [];
            $scope.ShowRaceChart = false;
            var RaceTally = 0;

            angular.forEach($scope.PrimaryData.Demographics[1].Data, function(value, key) {
                if (value.Value !== undefined) {
                    $scope.RaceChartLabels.push(value.Name);
                    $scope.RaceChartData.push(value.Value);
                    RaceTally = RaceTally + parseInt(value.Value);
                }
            });

            if (RaceTally > 0) {
                $scope.ShowRaceChart = true;

                if (RaceTally < TotalBeneficiaries) {
                    $scope.RaceChartLabels.push('Not Reported');
                    $scope.RaceChartData.push(TotalBeneficiaries - RaceTally);
                }
            }

            $scope.RacePopover = {
                templateUrl: 'race-popover.html',
            };

            // ### Beneficiary Age Pie Chart ###//

            $scope.AgeChartLabels = [];
            $scope.AgeChartData = [];
            $scope.ShowAgeChart = false;
            var AgeTally = 0;

            angular.forEach($scope.PrimaryData.Demographics[2].Data, function(value, key) {
                if (value.Value !== undefined) {
                    $scope.AgeChartLabels.push(value.Name);
                    $scope.AgeChartData.push(value.Value);
                    AgeTally = AgeTally + parseInt(value.Value);
                }
            });

            if (AgeTally > 0) {
                $scope.ShowAgeChart = true;

                if (AgeTally < TotalBeneficiaries) {
                    $scope.AgeChartLabels.push('Not Reported');
                    $scope.AgeChartData.push(TotalBeneficiaries - AgeTally);
                }
            }

            $scope.AgePopover = {
                templateUrl: 'age-popover.html',
            };

            // ### Beneficiary Dual Eligibility Pie Chart ###//

            $scope.EligibilityChartLabels = [];
            $scope.EligibilityChartData = [];
            $scope.ShowEligibilityChart = false;
            var EligibilityTally = 0;

            angular.forEach($scope.PrimaryData.Eligibility[0].Data, function(value, key) {
                if (value.Value !== undefined) {
                    $scope.EligibilityChartLabels.push(value.Name);
                    $scope.EligibilityChartData.push(value.Value);
                    EligibilityTally = EligibilityTally + parseInt(value.Value);
                }
            });

            if (EligibilityTally > 0) {
                $scope.ShowEligibilityChart = true;

                if (EligibilityTally < TotalBeneficiaries) {
                    $scope.EligibilityChartLabels.push('Not Reported');
                    $scope.EligibilityChartData.push(TotalBeneficiaries - EligibilityTally);
                }
            }

            $scope.EligibilityPopover = {
                templateUrl: 'eligibility-popover.html',
            };

            // ### Conditions Bar Chart ### //

            $scope.ConditionsData = [];
            $scope.ShowConditionsChart = false;
            var ConditionsTally = 0;

            angular.forEach($scope.PrimaryData.Conditions[0].Data, function(value, key) {
                if (value.Value !== undefined && value.Value != 0) {
                    var percentage = value.Value;

                    if ($scope.PrimaryDataKey == '2013') {
                        // In 2013, conditions were provided as decimals so we need compute the percentages
                        percentage = parseInt(value.Value * 100);
                    }

                    $scope.ConditionsData.push({Name: value.Name, Value: percentage});
                    ConditionsTally = ConditionsTally + percentage;
                }
            });

            if (ConditionsTally > 0) {
                $scope.ShowConditionsChart = true;
            }

            // ### Financial Bar Chart ### //

            $scope.FinancialChartSeries = [
                'Summary',
                'Medical',
                'Drug'
            ];

            $scope.FinancialChartLabels = [
                'Submitted',
                'Allowed',
                'Payment',
                'Standardized'
            ];

            $scope.FinancialChartData = [];
            var summaryArr = [];
            var medicalArr = [];
            var drugArr = [];
            var summaryTally = 0;
            var medicalTally = 0;
            var drugTally = 0;

            angular.forEach($scope.PrimaryData.Financial[0].Data, function(value, key) {
                if (value.TypeIdent == 1) {
                    if (value.Value == undefined) {
                        summaryArr.push(0);
                    }
                    else {
                        summaryArr.push(value.Value);
                        summaryTally = summaryTally + parseInt(value.Value);
                    }
                }
                if (value.TypeIdent == 3) {
                    if (value.Value == undefined) {
                        medicalArr.push(0);
                    }
                    else {
                        medicalArr.push(value.Value);
                        medicalTally = medicalTally + parseInt(value.Value);
                    }
                }
                if (value.TypeIdent == 2) {
                    if (value.Value == undefined) {
                        drugArr.push(0);
                    }
                    else {
                        drugArr.push(value.Value);
                        drugTally = drugTally + parseInt(value.Value);
                    }
                }
            });

            if (summaryTally > 0) {
                $scope.FinancialChartData.push(summaryArr);
            }
            if (medicalTally > 0) {
                $scope.FinancialChartData.push(medicalArr);
            }
            if (drugTally > 0) {
                $scope.FinancialChartData.push(drugArr);
            }

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


        init();

    }

  };

});