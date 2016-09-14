angular.module('App.zenReferrals', [])
.directive('zenReferrals', function() {
  return {
    restrict: 'E',
    replace: true,
    scope: {
        npi: '=',
        ident: '='
    },
    templateUrl: 'Entity/directives/zen-referrals.html',
    controller: function ($filter, $modal, $scope, $state, NgTableParams, zenOpenDataService) {

        $scope.LoadingReferralData = true;
        $scope.ReferralData = [];

        $scope.GetReferralData = function () {

            if ($scope.npi){

                zenOpenDataService.getReferralDataByNPI($scope.npi).then(function(data) {
                    $scope.ReferralData = data.Referrals;
                    $scope.LoadingReferralData = false;
                    //console.log($scope.ReferralData);
                },
                function(errorPl) {
                    $scope.LoadingReferralData = false;
                });

            } else {

                $scope.LoadingReferralData = false;

            };

        }; // GetReferralData

        $scope.OpenReferralModal = function () {

            $scope.ReferralModal = $modal.open({
                templateUrl: 'ReferralModal.html',
                scope: $scope,
                size: 'lg',
                windowClass: 'full'
            });

            var orderedData;

            $scope.tableParams = new NgTableParams({
                page: 1, // show first page
                count: 10, // count per page
                sorting: {
                    SharedTransactionCount: 'desc'
                }
            }, {
                counts: [5, 10, 25, 50, 100],
                //total: $scope.EntityProjectEntity.length, // length of data
                getData: function (params) {

                    orderedData = $scope.ReferralData;

                    //First do the sorting
                    orderedData = params.sorting() ? $filter('orderBy')(orderedData, params.orderBy()) : orderedData;

                    //Then the filtering
                    orderedData = params.filter() ? $filter('filter')(orderedData, params.filter()) : orderedData;

                    params.settings().total = orderedData.length;

                    //Then the paging
                    orderedData = orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count());

                    return orderedData;
                }

            });

        }; //OpenReferralModal


        $scope.GoToProfile = function (id) {
            $state.go('site.Profile', {ident: id});
            $scope.ReferralModal.close();
        }; //GoToProfile

        $scope.GetReferralData();

    }

  };

});