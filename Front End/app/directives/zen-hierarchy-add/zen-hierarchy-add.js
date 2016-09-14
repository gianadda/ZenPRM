angular.module('App.zenHierarchyAdd', [])
.directive('zenHierarchyAdd', function() {
  return {
    restrict: 'E',
    templateUrl: 'directives/zen-hierarchy-add/zen-hierarchy-add.html',
    scope: {
        organizationIdent: '@',
        reloadHierarchy: '='
    },
    controller: function (entityHierarchyService, growl, LookupTablesService, RESTService, $filter, $global, $rootScope, $scope, $timeout) {

        $scope.initZenHierarchyAdd = function(){

            $scope.newHierarchy = {};
            $scope.loadingResources = true;
            $scope.resourceSet = false;

            $scope.HierarchyType = [];
            $scope.resources = [];

            var searchCriteria = {
                resultsShown: 10000000
            };


            RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]), searchCriteria).then(function(pl) {

                $scope.resources = pl.data.Entities;
                $scope.loadingResources = false; 

            });

        }; //initZenHierarchyAdd

        $scope.getResources = function (val) {
            
            // search by name
            var results = $filter('filter')($scope.resources, {DisplayName: val});

            // if no results, search by NPI
            if (!results){
                results = $filter('filter')($scope.resources, {NPI: val});    
            };

            return results.slice(0,25); // just show top 25

        }; //getResources

        $scope.setResource = function (resource) {

            $scope.newHierarchy = {};
            $scope.newHierarchy = {
                FromEntityIdent: $scope.organizationIdent,
                ToEntityIdent: resource.Ident,
                DisplayName: resource.DisplayName
            };
            
            // rebind the type list by person/non-person
            $scope.HierarchyType = LookupTablesService.HierarchyType;
            $scope.HierarchyType = $filter('filter')($scope.HierarchyType, {ToEntityIsPerson: resource.Person}, true);

            $scope.resourceSet = true;

        }; //getResources

        $scope.addEntityHierarchy = function(ident){

            $scope.newHierarchy.HierarchyTypeIdent = ident;

            entityHierarchyService.addEntityHierarchy($scope.newHierarchy).then(function (data) {

                    growl.success($global.GetRandomSuccessMessage());

                    $scope.newHierarchy = {};
                    $scope.resourceSet = false;
                    $scope.reloadHierarchy();

                }); //entityHierarchyService.addEntityHierarchy

        };

        $scope.initZenHierarchyAdd();

    } // controller

  };

});