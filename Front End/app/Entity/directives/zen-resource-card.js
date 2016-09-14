angular.module('App.zenResourceCard', ['ui.bootstrap'])
.directive('zenResourceCard', function() {
  return {
    restrict: 'E',
    scope: {
        entity: '='
    },
    templateUrl: 'Entity/directives/zen-resource-card.html',
    controller: function ($scope, $sce) {

        // Write out email address HTML
        $scope.TrustEmailHTML = function(email) {
            return $sce.trustAsHtml(email);
        }

    }

  };

});