'use strict'

angular
    .module('App.ProjectParticipantsController', [])
    .controller('ProjectParticipantsController', [
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
    'NgTableParams',
    '$sce',
    '$stateParams',
    'entityProjectService',
    '$modal',
function ($scope, $rootScope, $log, $filter, $timeout, $interval, $http, $global, RESTService, growl, $window, identity, NgTableParams, $sce, $stateParams, entityProjectService, $modal) {

            //setup navigation
            $rootScope.currentProjectIdent = $stateParams.ident;
            $rootScope.currentlySelectedProjectTab = 'Participants';

            $scope.sendEmailMessage = '';
            $scope.projectEmailSent = false;

            $scope.loadingProviders = false;
            $scope.EntityProjectEntity = [];
            $scope.EntityProjectEntityCounts = {};
            $scope.ReloadGrid = false;
            $scope.newParticipant = {};
            $scope.loading = false;

            $scope.$watch("ReloadGrid", function () {
                $scope.tableParams.reload();
                $scope.ReloadGrid = false;
            });

            var orderedData;
            var fullOrderedData;

            $scope.tableParams = new NgTableParams({
                page: 1, // show first page
                count: 10, // count per page
                sorting: {
                    DisplayName: 'asc'
                }
            }, {
                counts: [5, 10, 25, 50, 100],
                //total: $scope.EntityProjectEntity.length, // length of data
                getData: function (params) {

                    orderedData = $scope.EntityProjectEntity;

                    //First do the sorting
                    orderedData = params.sorting() ? $filter('orderBy')(orderedData, params.orderBy()) : orderedData;

                    //Then the filtering
                    orderedData = params.filter() ? $filter('filter')(orderedData, params.filter()) : orderedData;

                    fullOrderedData = orderedData;

                    params.settings().total = orderedData.length;

                    //Then the paging
                    orderedData = orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count());

                    return orderedData;
                }

            });

            $scope.init = function () {

                $scope.loading = true;

                var searchCriteria = [{
                                name: "bolIncludeParticipants",
                                value: true
                        },{
                                name: "bolIncludeAnswerCount",
                                value: true
                        }];

                var getEntityProjectRequirements = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTDETAILS]), searchCriteria, $stateParams.ident);

                getEntityProjectRequirements.then(function (pl) {

                    $scope.EntityProject = pl.data.EntityProject[0];
                    $scope.EntityProjectEntity = pl.data.EntityProjectEntity;
                    $scope.EntityProjectEntityCounts = pl.data.EntityProjectEntityCounts[0];

                    angular.forEach($scope.EntityProjectEntity, function (key, val) {

                        $scope.EntityProjectEntity[val].ProjectData =
                            Math.round((key.TotalEntityProjectEntityEntityProjectAnswers / key.TotalEntityProjectEntityEntityProjectRequirement) * 100);
                    })

                    $scope.ReloadGrid = true;
                    
                    $scope.loading = false;

                    $rootScope.PageTitle = $scope.EntityProject.Name1 + ' - Participants';
                });

            };

            $scope.RemoveEntityFromProject = function (EntityToRemoveIdent) {
                var putData = {
                    EntityProjectIdent: $scope.EntityProject.Ident,
                    EntityIdent: EntityToRemoveIdent
                };

                var removeFromProjectPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREMOVEENTITYFROMPROJECT]), putData);

                removeFromProjectPost.then(function (pl) {
                        $scope.init();
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function (errorPl) {
                        $scope.init();
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            //Ensure that there is a debounce on the typeing filter
            var timeoutPromise;
            var delayInMs = 1000;
            $scope.getProviders = function (val) {
                $scope.loadingProviders = true;
                $timeout.cancel(timeoutPromise); //does nothing, if timeout alrdy done
                timeoutPromise = $timeout(function () { //Set timeout
                    return $scope.getProvidersNow(val);
                }, delayInMs);
                return timeoutPromise;
            };

            $scope.getProvidersNow = function (val) {

                var searchCriteria = [{
                    name: "keyword",
                    value: val
                }];

                var path = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT, $rootScope.currentProjectIdent, $global.RESTControllerNames.ENTITY]);

                var getProviders = RESTService.getWithParams(path, searchCriteria);

                return getProviders.then(function (pl) {

                        $scope.loadingProviders = false;
                        return pl.data;

                    },
                    function (errorPl) {

                        $scope.loadingProviders = false;
                        return [];
                    }
                );

            };

            $scope.setProvider = function (provider) {

            };

            $scope.addProviderToProject = function () {

                var putData = {
                    EntityProjectIdent: $rootScope.currentProjectIdent,
                    EntityIdent: $scope.newParticipant.provider.Ident
                };

                var addToProjectPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTADDENTITYTOPROJECT]), putData);

                addToProjectPost.then(function (pl) {
                        $scope.newParticipant = {};
                        $scope.init();
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            };

            $scope.IncludeEntireNetwork = function() {
                var putProject = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), $rootScope.currentProjectIdent, $scope.EntityProject);

                    putProject.then(function (pl) {

                            growl.success($global.GetRandomSuccessMessage());
                            //rebind after save
                            $scope.init();

                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });

            }

            $scope.showSendProjectEmailModal = function() {

                $scope.projectEmailSent = false;
               
                //(Setup) the modal and keep it in scope so we can call functions on it.
                $scope.SendProjectEmailModal = $modal.open({
                    animation: true,
                    templateUrl: 'SendProjectEmailModal.html',
                    scope: $scope,
                    size: 'lg'
                });

                $scope.SendProjectEmailModal.sendProjectNotificationEmail = function(){

                    $scope.sendEmailMessage = '';
                    $scope.loading = true;
                    $scope.projectEmailSent = true;

                    entityProjectService.sendProjectEmail($rootScope.currentProjectIdent, $scope.SendProjectEmailModal.emailCustomMessage).then(function (pl) {

                            $scope.SentNotificationCounts = pl.data.resultCounts[0];

                            //reload the grid with the updated notification info
                            $scope.init();
                            
                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());     
                            $scope.loading = false;
                        });

                };


            };

            var modalAlreadyOpen = false;
            $rootScope.modalHeight = { 'height': 'auto' };

            $scope.loadAnswerModal = function(index) {
                // Prev or Next button have been pressed and we already have the correct index
                if (modalAlreadyOpen) {
                    $rootScope.currentIndex = index;
                }
                // Button was pressed to open modal and we need to factor in paging to get the correct index
                else {
                    $rootScope.currentIndex = ( ($scope.tableParams.page() - 1) * $scope.tableParams.count() ) + index;
                }

                // Draw previous and next buttons
                $rootScope.showPrevBtn = true;
                if ($rootScope.currentIndex == 0) {
                    $rootScope.showPrevBtn = false;
                }

                $rootScope.showNextBtn = true;
                if ( ($rootScope.currentIndex + 1) == fullOrderedData.length ) {
                    $rootScope.showNextBtn = false;
                }

                // Show name of current participant
                $rootScope.currentParticipant = fullOrderedData[$rootScope.currentIndex].FullName;

                // Load current participant answers
                $stateParams.entityIdent = fullOrderedData[$rootScope.currentIndex].Ident;

                // Hide title bar and contact info in modal, show "quick save" button
                $rootScope.AnswerMode = true;

                // Open modal
                $rootScope.AnswerModal = $modal.open({
                    animation: !modalAlreadyOpen,
                    templateUrl: 'AnswerModal.html',
                    scope: $rootScope,
                    size: 'lg',
                    backdrop: 'static',
                    keyboard: false
                });

                $rootScope.modalLoading = false;

            };

            $rootScope.nextProject = function(index) {
                modalAlreadyOpen = true;
                $rootScope.Save();
                $rootScope.setModalHeight();
                $rootScope.AnswerModal.close();
                $scope.loadAnswerModal(index + 1);
            }

            $rootScope.prevProject = function(index) {
                modalAlreadyOpen = true;
                $rootScope.Save();
                $rootScope.setModalHeight();
                $rootScope.AnswerModal.close();
                $scope.loadAnswerModal(index - 1);
            }

            $rootScope.saveAnswers = function() {
                // Call save function in project.js
                $rootScope.Save();
            }

            $rootScope.closeAnswers = function() {
                // Reload grid to update % complete
                $scope.init();

                // Set grid to correct page
                var currentPage = Math.ceil( ($rootScope.currentIndex + 1) / $scope.tableParams.count() );
                $scope.tableParams.page(currentPage);
                
                // Reset
                $rootScope.showPrevBtn = false;
                $rootScope.showNextBtn = false;
                $rootScope.AnswerMode = false;
                $rootScope.AnswerModal.close();
                modalAlreadyOpen = false;
            }

            $rootScope.setModalHeight = function() {
                if ( $rootScope.modalHeight.height == 'auto' ) {
                    $rootScope.modalHeight = { 'height': document.getElementById('modAnswer').offsetHeight + 'px' };
                }
            }

            $scope.init();

}]);