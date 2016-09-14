angular.module('App.zenProject', [])
.directive('zenProject', function() {
  return {
    restrict: 'E',
    scope: {
    	project: '=project',
        adminMode: '=',
        reloadProjects: '=',
        showArchive: '=',
        showBookmark: '=',
        showReactivate: '=',
        showOrgLabel: '=',
    },
    templateUrl: 'directives/zen-project/zen-project.html',
    controller: function ($scope, $rootScope, $global, $state, RESTService, entityProjectService) {

        // Set class
        if ( $scope.project.Archived || $scope.project.PercentComplete == '0.00') {
            $scope.projectClass = 'project-empty';
        }
        else if ( $scope.project.PercentComplete == '100.00' ) {
            $scope.projectClass = 'project-success';
        }
        else {
            $scope.projectClass = 'project-default';
        }


        // Set link
        $scope.ProjectLink = function() {
            // If in admin mode, link to Project Details
            if ($scope.adminMode) {
                $state.go('site.ProjectDetail', {ident: $scope.project.Ident})
            }
            // Otherwise, link to Resource Answers
            else {
                $state.go('site.Project', {ident: $scope.project.Ident, entityIdent: $rootScope.CurrentProfileEntityIdent});
            }
        }


        $scope.ArchiveProject = function(Ident) {

            var postEntityProject;
            var postData = {
                EntityProjectIdent: Ident
            }
            postEntityProject = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTARCHIVE]), postData);

            return postEntityProject.then(function(pl) {

                    $scope.reloadProjects();
                },
                function(errorPl) {
                    growl.error($global.GetRandomErrorMessage());

                }
            );

        }


        $scope.ReactivateProject = function(Ident) {

            entityProjectService.ReactivateProject(Ident).then(function(pl){

                    $scope.reloadProjects();
                },
                function(errorPl) {
                    growl.error($global.GetRandomErrorMessage());

                }
            );

        };


        // Numberify percent complete
        $scope.drawComplete = function(percent) {
            return parseInt(percent);
        }

    }

  };

});