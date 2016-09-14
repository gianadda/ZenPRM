'use strict'

angular
    .module('App.ProjectDetailController', ["chart.js"])
    .controller('ProjectDetailController', [
        '$scope',
        '$rootScope',
        '$log',
        '$filter',
        '$timeout',
        '$interval',
        '$http',
        '$global',
        'RESTService',
        'growl',
        '$window',
        'identity',
        'LookupTablesService',
        'MyProfileService',
        '$sce',
        '$state',
        '$stateParams',
        'entityProjectMeasuresService',
        function($scope, $rootScope, $log, $filter, $timeout, $interval, $http, $global, RESTService, growl, $window, identity, LookupTablesService, MyProfileService, $sce, $state, $stateParams, entityProjectMeasuresService) {


            $scope.LookupTables = LookupTablesService;
            $scope.loadingPage = false;

            $scope.Pielabels = ["Submitted Requirements", "Open Requirements"];

            //setup navigation
            $rootScope.currentProjectIdent = $stateParams.ident;
            $rootScope.currentlySelectedProjectTab = 'Overview';

            $scope.init = function() {
            
                identity.identity()
                    .then(function() {
                        $scope.MyIdent = identity.getUserIdent();
                        MyProfileService.getProfile($scope.MyIdent).then(function(pl) {
                                $scope.CurrentEntity = pl;
                            },
                            function(errorPl) {
                                growl.error($global.GetRandomErrorMessage());

                            });
                    });

                $scope.LoadingMeasures = true;
                $scope.GetMeasuresData();

            }

            $scope.TrustEmailHTML = function(email) {
                return $sce.trustAsHtml(email);
            }

            $scope.IsCustomer = function() {
                return $global.isCustomer();
            }

            $scope.LoadEntityProjectRequirements = function() {

                var searchCriteria = [{
                    name: "bolIncludeQuestions",
                    value: true
                }, {
                    name: "bolIncludeAnswerCount",
                    value: true
                }];

                var getEntityProjectRequirements = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTDETAILS]), searchCriteria, $stateParams.ident);

                getEntityProjectRequirements.then(function(pl) {

                        $scope.formControls = $filter('filter')(pl.data.EntityProjectRequirement, { RequiresAnswer: true }, true);

                        $scope.EntityProject = pl.data.EntityProject[0];

                        $timeout(function() {
                            //DOM has finished rendering
                            $scope.init();
                        });

                        $rootScope.PageTitle = $scope.EntityProject.Name1;
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            $scope.calculatePercentage = function(val) {
                var percentage = parseFloat(val) / parseFloat($scope.TotalResults);
                percentage = (percentage * 100).toFixed(2);
                return percentage;
            }


            // MEASURES //

            // Fetch measure data from end point
            $scope.GetMeasuresData = function () {

                 entityProjectMeasuresService.getProjectDials($stateParams.ident).then(function (data) {
                        $scope.MeasuresData = data;
                        
                        if ($scope.MeasuresData.length > 1) {
                            $scope.colClass = 'col-sm-6 col-md-12 col-lg-6';
                        }
                        else {
                            $scope.colClass = 'col-xs-12';
                        }

                        $scope.LoadingMeasures = false;
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.MeasuresData = [];
                        $scope.LoadingMeasures = false;
                    });

            }; //GetMeasuresData

            $scope.AddNewMeasure = function() {
                $scope.$broadcast('openNewDialModel',{});
            };

            $scope.MeasureClick = function (measure) {
                $state.go('site.measures', {ident: measure.Ident, tab: 'dials'});
            }


            // Load answers
            $scope.LoadEntityProjectRequirements();

        }
    ]);
