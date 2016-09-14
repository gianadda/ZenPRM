angular.module('App.zenOrgCard', [])
.directive('zenOrgCard', function() {
  return {
    restrict: 'E',
    replace: true,
    scope: {
        entity: '='
    },
    templateUrl: 'Entity/directives/zen-org-card.html',
    controller: function ($scope, $sce) {

        $scope.EntityData = $scope.entity.Entity[0];
        $scope.TaxonomyData = $scope.entity.Taxonomy;
        $scope.ServiceData = $scope.entity.Services;
        $scope.ResourceName = $scope.name;

        // Write out email address HTML
        $scope.TrustEmailHTML = function(email) {
            return $sce.trustAsHtml(email);
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

    }

  };

});