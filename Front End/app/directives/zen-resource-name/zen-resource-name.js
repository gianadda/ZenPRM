angular.module('App.zenResourceName', [])
.directive('zenResourceName', function() {
  return {
    restrict: 'E',
    scope: {
        name: "=",
        ident: "=",
        photo: "=",
        class: "="
    },
    templateUrl: 'directives/zen-resource-name/zen-resource-name.html',
    controller: function (MyProfileService, $global, $scope, $modal, $state, $sce, $filter, LookupTablesService, entityNetworkService, entityHierarchyService) {

    	// Load Preview data
        $scope.LoadPreview = function (ResourceIdent) {

        	// Only get data from API if not already in scope
            if ($scope.EntityData == undefined){

                MyProfileService.getProfile(ResourceIdent).then(function(pl) {
                        $scope.EntityData = pl.Entity[0];
                        $scope.SpecialtyData = pl.Speciality;
                        $scope.Emails = pl.EntityEmail;
                        
                        $scope.GetHierarchyData();
                        $scope.OpenPreview();

                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }
            else {
            	$scope.OpenPreview();
            };

        }; // LoadTooltip

        // Load Resource hierarchy
        $scope.GetHierarchyData = function () {
            // Get hierarchy for Resource
            entityHierarchyService.GetEntityHierarchy($scope.EntityData.Ident, true).then(function(data) {
                $scope.HierarchyData = data;
            });
        };

        // Open Preview modal
        $scope.OpenPreview = function () {

            // Show larger modal for providers
            var size;
            if ( $scope.EntityData.EntityTypeIdent == 3 ) {
                size = 'md';
            }
            else {
                size = 'md';
            }

            $scope.ResourcePreview = $modal.open({
                animation: true,
                templateUrl: 'ResourcePreview.html',
                size: size,
                scope: $scope,
                windowClass: 'card theme-' + $scope.EntityData.EntityTypeIdent
            });
        }

        // Check to see if resource has any contact information
        $scope.CheckContactInfo = function () {
            if ($scope.EntityData.PrimaryAddress1 || $scope.EntityData.PrimaryCity || ($scope.EntityData.PrimaryState && $scope.EntityData.PrimaryZip) || $scope.EntityData.PrimaryPhone || $scope.EntityData.Email) {
                return true;
            }
            else {
                return false;
            }
        }

        // View full profile
        $scope.GoToProfile = function (id) {
            $state.go('site.Profile', {ident: id});
            $scope.ResourcePreview.close();
        }

        // Edit profile
        $scope.EditProfile = function (id) {
            $state.go('site.EditProfile', {ident: id});
            $scope.ResourcePreview.close();
        }

        // Display email addresses nicely
        $scope.TrustEmailHTML = function (email) {
            return $sce.trustAsHtml(email);
        }

    }

  };

});