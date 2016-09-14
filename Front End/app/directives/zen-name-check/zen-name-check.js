angular.module('App.zenNameCheck', [])
.directive('zenNameCheck', function() {
  return {
    restrict: 'E',
    scope: {
        entity: "=entity"
    },
    templateUrl: 'directives/zen-name-check/zen-name-check.html',
    controller: function ($scope, $http, zenOpenDataService) {

        // Check Resource name against NPPES and PECOS
        $scope.PecosMatch = false;
        $scope.NppesMatch = false;

        $scope.PecosPopover = {
            templateUrl: 'Pecos-Popover.html'
        }
        $scope.NppesPopover = {
            templateUrl: 'Nppes-Popover.html'
        }

        var CheckName = function () {

            // Only make the request if we have an NPI
            if ($scope.entity.NPI) {

                // PECOS
                $http({
                    method: 'GET',
                    url: 'https://data.cms.gov/resource/7b6b-dk5v.json?$$app_token=58ITGpt24AV5YxJiEbj5y5Lua&npi=' + $scope.entity.NPI
                    }).then(function PecosGood(response) {

                        if (response.data.length > 0) {

                            $scope.PecosData = response.data[0];
                            var PecosFirstName = $scope.PecosData.first_name.toLowerCase();
                            var PecosLastName = $scope.PecosData.last_name.toLowerCase();

                            if ($scope.entity.FirstName.toLowerCase() == PecosFirstName && 
                                $scope.entity.LastName.toLowerCase() == PecosLastName) {

                                $scope.PecosMatch = true;
                                $scope.PecosClass = 'fa-thumbs-up';

                            }
                            else {
                                $scope.PecosClass = 'fa-thumbs-down';
                            }

                        }
                        else {
                            $scope.PecosClass = 'fa-ban';
                        }

                    }, function PecosError(response) {
                        $scope.PecosClass = 'fa-ban';
                    });

                // NPPES
                zenOpenDataService.getEntityByNPI($scope.entity.NPI)
                    .then(function NppesGood(response) {

                        if (response.data) {

                            $scope.NppesData = response.data.results[0];
                            var NppesFirstName = $scope.NppesData.basic.first_name.toLowerCase();
                            var NppesLastName = $scope.NppesData.basic.last_name.toLowerCase();

                            if ($scope.entity.FirstName.toLowerCase() == NppesFirstName && 
                                $scope.entity.LastName.toLowerCase() == NppesLastName) {

                                $scope.NppesMatch = true;
                                $scope.NppesClass = 'fa-thumbs-up';

                            }
                            else {
                                $scope.NppesClass = 'fa-thumbs-down';
                            }

                        }
                        else {
                            $scope.NppesClass = 'fa-ban';
                        }

                    },
                    function NppesError(response) {
                        $scope.NppesClass = 'fa-ban';
                    });

            }
            else {
                $scope.PecosClass = 'fa-exclamation-triangle';
                $scope.NppesClass = 'fa-exclamation-triangle';
            }

        }

        $scope.SupportsNPI = function () {
            // Only Orgs, Providers & Facilities can have NPIs
            if ($scope.entity.EntityTypeIdent == 2 || $scope.entity.EntityTypeIdent == 3 || $scope.entity.EntityTypeIdent == 4) {
                return true;
            }
            else {
                return false;
            }
        }

        CheckName();

    }

  };

});