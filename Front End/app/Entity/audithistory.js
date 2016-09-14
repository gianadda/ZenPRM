angular
    .module('App.AuditHistoryController', [])
    .controller('AuditHistoryController', [
    '$scope',
    '$rootScope',
    '$filter',
    '$timeout',
    '$global',
    'RESTService',
    'MyProfileService',
    '$state',
    '$stateParams',
    'NgTableParams',
    '$sce',
    'ZenValidation',
    'identity',
function ($scope, $rootScope, $filter, $timeout, $global, RESTService, MyProfileService, $state, $stateParams, NgTableParams, $sce, ZenValidation, identity) {

            $scope.Filter = '';
            $scope.ZenValidation = ZenValidation;
            $scope.loading = true;
            
            $scope.EntityIdent = $stateParams.ident;
            $scope.EntityLoaded = false;

            //Ensure that there is a debounce on the typeing filter
            var timeoutPromise;
            var delayInMs = 1000;
            $scope.$watch("Filter", function (newValue, oldValue) {
                if (oldValue !== newValue) {
                    $timeout.cancel(timeoutPromise); //does nothing, if timeout alrdy done
                    timeoutPromise = $timeout(function () { //Set timeout
                        $scope.tableParams.reload();
                    }, delayInMs);
                }
            });


            if ($stateParams.ident) {

                $rootScope.CurrentProfileEntityIdent = $stateParams.ident;
                MyProfileService.getProfile($stateParams.ident).then(function (pl) {
                        $scope.EntityDetails = pl.Entity[0];
                        $scope.EntityLoaded = true;

                        $scope.LoadAuditHistory();
                        
                        $rootScope.PageTitle = $scope.EntityDetails.FullName + ' - Audit History';
                    },
                    function (errorPl) {
                        $scope.EntityLoaded = true;
                        $scope.loading = false;
                    });
            } else {
                $state.go('site.notfound');
            }

            $scope.LoadAuditHistory = function () {

                var entityNetworkGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.AUDITHISTORY]), $stateParams.ident);

                return entityNetworkGet.then(function (pl) {
                        $scope.AuditHistory = pl.data.ASUserActivity;
                        $scope.tableParams.reload();
                        $scope.loading = false;
                    },
                    function (errorPl) {
                        $scope.loading = false;
                    });

            }

            $scope.CleanUpTableAndColumnName = function (s) {
                // s.replace("Ident")
                s = s.replace("Services1", "Services");
                s = s.replace("Ident", "");
                s = s.replace("XRef", "");
                s = s.replace(/([a-z])([A-Z])/g, '$1 $2');

                return s.trim();
            }

            function preg_quote(str) {
                // http://kevin.vanzonneveld.net
                // +   original by: booeyOH
                // +   improved by: Ates Goral (http://magnetiq.com)
                // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
                // +   bugfixed by: Onno Marsman
                // *     example 1: preg_quote("$40");
                // *     returns 1: '\$40'
                // *     example 2: preg_quote("*RRRING* Hello?");
                // *     returns 2: '\*RRRING\* Hello\?'
                // *     example 3: preg_quote("\\.+*?[^]$(){}=!<>|:");
                // *     returns 3: '\\\.\+\*\?\[\^\]\$\(\)\{\}\=\!\<\>\|\:'

                return (str + '').replace(/([\\\.\+\*\?\[\^\]\$\(\)\{\}\=\!\<\>\|\:])/g, "\\$1");
            }

            $scope.highlightSearchValue = function (value, fieldName) {

                if (fieldName == 'ProfilePhoto' && $scope.ZenValidation.ValidImageURL(value) && value.trim().length > 0) {
                    //This means it's an image URL
                    return $sce.trustAsHtml("<img src='" + value + "' height='100' /> ");
                }

                if ($scope.Filter === '') {
                    return $sce.trustAsHtml(value);
                } else {
                    return $sce.trustAsHtml(value.replace(new RegExp("(" + preg_quote($scope.Filter) + ")", 'gi'), "<b class='bg-primary'>$1</b>"));

                }

            }

            $scope.getMomentDate = function (date) {
                return moment(date).format('MMMM Do YYYY, h:mm:ss a');
                // return moment(date).fromNow();

            }

            $scope.GetEntryHeaderDetails = function (ident) {
                return $filter('filter')($scope.AuditHistory, {
                    Ident: ident
                }, true)[0];

            }

            $scope.tableParams = new NgTableParams({
                page: 1, // show first page
                count: 10000, // count per page,
                group: function (item) {
                    return item.Ident;
                }
            }, {
                counts: [], // hide page counts control
                total: $scope.AuditHistory ? $scope.AuditHistory.length : 0,
                getData: function (params) {

                    var orderedData = $scope.AuditHistory ? $scope.AuditHistory : [];

                    orderedData = $filter('filter')(orderedData, $scope.Filter);

                    orderedData = $filter('orderBy')(orderedData, "-ActivityDateTime")

                    orderedData = orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count());

                    return orderedData;
                }
            });

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

}]);