angular
    .module('App.ReportController', [])
    .controller('ReportController', [
        '$scope',
        '$rootScope',
        '$timeout',
        '$global',
        'growl',
        '$stateParams',
        '$state',
        'MyProfileService',
        'identity',
        'RESTService',
        '$compile',
        'entityReportService',
        'entityProjectMeasuresService',
        function($scope, $rootScope, $timeout, $global, growl, $stateParams, $state, MyProfileService, identity, RESTService, $compile, entityReportService, entityProjectMeasuresService) {

            $scope.EntityIdent = $stateParams.entityident;
            $scope.ReportIdent = $stateParams.reportident;

            $scope.EntityLoaded = false;
            $scope.ReportLoaded = false;

    
            $scope.init = function() {

                if ($scope.EntityIdent) {

                    MyProfileService.getProfile($scope.EntityIdent).then(function(pl) {
                            $scope.EntityData = pl;
                            $scope.EntityDetails = $scope.EntityData.Entity[0];
                            $scope.EntityLoaded = true;

                            $rootScope.PageTitle = $scope.EntityDetails.FullName + ' - Reports';

                            LoadReport();
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                            $scope.EntityLoaded = true;
                        });

                } else {
                    $state.go('site.notfound');
                }

            };


            var LoadReport = function() {

                entityReportService.getEntityReport($scope.ReportIdent).then(function(data) {
                        $scope.Report = data.EntityReport[0];
                        
                        BuildReport();
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.ReportLoaded = true;
                    });

            }


            var BuildReport = function() {

                // Load resource measures (could apply to Providers or Organizations)
                entityProjectMeasuresService.getResourceDials($scope.EntityIdent).then(function(data) {
                        $scope.ReportMeasureData = [];
                        
                        angular.forEach(data, function(measure) {
                            $scope.ReportMeasureData.push({ MeasureIdent: measure.Ident, MeasureData: measure });
                        })
                        
                        $scope.ReportLoaded = true;
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            };

            // HELPER FUNCTIONS //

            $scope.IsCustomer = function() {
                return $global.isCustomer();
            }

            $scope.IsMyProfile = function(ident) {
                var bolValid = false;
                if (identity.getUserIdent() == ident) {
                    bolValid = true;
                }
                return bolValid;
            }

            $scope.Loaded = function() {
                if ($scope.EntityLoaded) {
                    return true;
                }
            }

            $scope.init();

        }
    ]);
