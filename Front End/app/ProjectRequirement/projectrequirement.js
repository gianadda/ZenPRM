angular
    .module('App.ProjectRequirementController', [])
    .controller('ProjectRequirementController', [
    '$scope',
    '$rootScope',
    'growl',
    '$stateParams',
    '$filter',
    'entityProjectMeasuresService',
    'entityProjectService',
    '$state',
function ($scope, $rootScope, growl, $stateParams, $filter, entityProjectMeasuresService, entityProjectService, $state) {

            //setup navigation
            $rootScope.currentProjectIdent = $stateParams.ident;
            $rootScope.currentTab = $stateParams.tab;

            // Call functions on load
            $scope.init = function () {
                //$scope.dialClass = ;

                $scope.RequirementData = [];
                $scope.ProjectQuestions = [];
                $scope.EntityProjectRequirement = {};

                // Load tab
                $scope.EntityProjectIdent = $stateParams.ident;
                $scope.requirementIdent = $stateParams.questionident;
                $scope.CurrentTab = $stateParams.tab;

                $scope.GetRequirementData();

                $scope.GetProjectQuestions();



            };

            // Fetch measure data from end point
            $scope.GetRequirementData = function (measureTypeIdent) {

                $scope.loading = true;

                 entityProjectMeasuresService.getRequirementHierarchy($scope.requirementIdent, measureTypeIdent).then(function (data) {
                        $scope.RequirementData = data;
                        $scope.RequirementName = $scope.RequirementData.EntityMeasure;
                        $scope.loading = false;

                        // if we are on the dials tab, show the selected state
                        if ($scope.CurrentTab == 'dials'){

                            // if only one, selected that dial
                            if ($scope.RequirementData.EntityMeasureTotal.length == 1){
                                $scope.RequirementData.EntityMeasureTotal[0].Selected = true;
                            } else if (measureTypeIdent) { // else if we select a type
                                $filter('filter')($scope.RequirementData.EntityMeasureTotal, {MeasureTypeIdent: measureTypeIdent},true)[0].Selected = true;
                            } else {
                                // select the default of "count"
                                $filter('filter')($scope.RequirementData.EntityMeasureTotal, {MeasureTypeIdent: 6},true)[0].Selected = true;

                            };

                        }; //if ($scope.CurrentTab == 'dials')

                        if ( $scope.RequirementName && $scope.ProjectName ) {
                            $rootScope.PageTitle = $scope.ProjectName + ' - ' + $scope.RequirementName + ' Report';
                        }

                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.RequirementData = [];
                        $scope.loading = false;
                    });

            }; // GetRequirementData

            $scope.GetProjectQuestions = function () {

                entityProjectService.getEntityProject($scope.EntityProjectIdent).then(function (pl) {
                    $scope.ProjectName = pl.data.EntityProject[0].Name1;
                    $scope.ProjectQuestions = $filter('filter')(pl.data.EntityProjectRequirement, {RequiresAnswer: true}, true);
                    $scope.EntityProjectRequirement = $filter('filter')($scope.ProjectQuestions, {Ident: parseInt($scope.requirementIdent)}, true)[0];
                    
                    // Previous and next buttons
                    $scope.currIndex = $scope.ProjectQuestions.indexOf($scope.EntityProjectRequirement);
                    // Previous
                    if ($scope.currIndex > 0) {
                        $scope.prevIdent = $scope.ProjectQuestions[$scope.currIndex - 1].Ident;
                    }
                    // Next
                    if ($scope.currIndex + 1 < $scope.ProjectQuestions.length) {
                        $scope.nextIdent = $scope.ProjectQuestions[$scope.currIndex + 1].Ident;
                    }

                });

                

            }; // GetProjectQuestions

            $scope.MeasureClick = function (measure, firstLoad) {
                
                 $scope.GetRequirementData(measure.MeasureTypeIdent);

            }; // MeasureClick

            $scope.changeQuestion = function(){

                $state.go('site.ProjectDetail.Question', {questionident: $scope.EntityProjectRequirement.Ident});

            }; // changeQuestion

            $scope.GoBack = function() {
                window.history.back();
            }

            $scope.init();

}]);