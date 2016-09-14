angular.module('App.zenEntityNav', [])
.directive('zenEntityNav', function() {
  return {
    restrict: 'E',
    scope: {
        entity: '=',
    },
    templateUrl: 'Entity/directives/zen-entity-nav.html',
    controller: function ($scope, $global, identity) {

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

        $scope.showMenu = false;
        $scope.toggleMenu = function() {
            $scope.showMenu = !$scope.showMenu;
        }

    }

  };

});