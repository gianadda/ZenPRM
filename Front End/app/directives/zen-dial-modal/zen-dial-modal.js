angular.module('App.zenDialModal', [])
.directive('zenDialModal', function() {
  return {
    restrict: 'E',
    scope: {
        measure: '=measure',
        reloadDials: '='
    },
    templateUrl: 'directives/zen-dial-modal/zen-dial-modal.html',
    controller: function (growl, entityProjectMeasuresService, LookupTablesService, MyProfileService, RESTService, $filter, $global, $modal, $rootScope, $scope, $timeout) {

            // -------------------------------------------------------------- //
            // ADD DIAL //

            // Get measure types
            $scope.MeasureTypes = LookupTablesService.MeasureType;
            $scope.MeasureLocation = LookupTablesService.MeasureLocation;

            $scope.addMode = true;

            if ($scope.measure){
                $scope.addMode = false;
            };

            $scope.initDialModal = function() {
        
                $scope.ShowRangeError = false;

                // Edit Mode
                if (!$scope.addMode){

                    MyProfileService.getProfile().then(function (pl) {

                            $scope.projects = pl.EntityProject;

                            $scope.LoadProjectQuestions($scope.measure.EntityProject1Ident, 1, $scope.measure.DataTypeIdent);

                            if ($scope.measure.EntityProject2Ident && $scope.measure.EntityProject2Ident > 0){
                                $scope.LoadProjectQuestions($scope.measure.EntityProject2Ident, 2, $scope.measure.DataTypeIdent);
                            };

                            $scope.NewRange = {};

                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());

                        });

                }
                // Add Mode
                else {
                    // new add, reset values
                    $scope.measure = {};
                    $scope.measure.Ranges = [];
                    $scope.measure.Location = [];
                    $scope.measure.EntitySearchIdent = 0;
                    $scope.NewRange = {};
                    $scope.ProjectQuestions1 = [];
                    $scope.ProjectQuestions2 = [];

                    // on add mode, default all locations to be selected
                    angular.forEach($scope.MeasureLocation, function(value, key) {

                        var Location = {
                            Ident: 0,
                            EntityProjectMeasureIdent: 0,
                            MeasureLocationIdent: value.Ident,
                            LocationName: value.Name1,
                            LocationDescription: value.Desc1,
                            Selected: true

                        };
                        
                        $scope.measure.Location.push(Location);

                    });

                    MyProfileService.getProfile().then(function (pl) {

                            $scope.projects = pl.EntityProject;

                    });

                };

            };

            // Load questions for selected project
            $scope.LoadProjectQuestions = function(EntityProjectIdent, number, dataTypeIdent) {
                var getEntityProject = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), EntityProjectIdent);

                getEntityProject.then(function(pl) {

                        var questions = [];

                        // for now, we're excluding specific project questions from creating dials. its ones like Address, Hours of Op, File Upload
                        var initQuestions = $filter('filter')(pl.data.EntityProjectRequirement, {AllowEntityProjectMeasure: true}, true);

                        // if the measure type filters by a specific data type, we need to filter the questions here
                        if (dataTypeIdent > 0){
                            questions = $filter('filter')(initQuestions, {EntitySearchDataTypeIdent: dataTypeIdent}, true);
                        } else {
                            questions = initQuestions;
                        };

                        if (number == 1){
                            $scope.ProjectQuestions1 = questions;
                        } else {
                            $scope.ProjectQuestions2 = questions;
                        };

                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            };


            // Check to see is the Add Dial form is valid
            $scope.IsDialFormInvalid = function () {
                // These fields are required in all cases
                if ( $scope.measure.MeasureName == undefined || $scope.measure.MeasureTypeIdent == undefined || $scope.measure.Question1EntityProjectRequirementIdent == undefined ) {
                    return true;
                }
                // Check if Name text has been deleted
                else if ( $scope.measure.MeasureName == '' ) {
                    return true;
                }
                // If a denominator is required, make sure that value exists
                else if ( $scope.HasDenominator($scope.measure.MeasureTypeIdent) && $scope.measure.Question2EntityProjectRequirementIdent == undefined ) {
                    return true;
                }
                else {
                    return false;
                }
            }

            $scope.GetNewMeasureTypeSettings = function(measureTypeIdent){

                var dataTypeIdent;
                dataTypeIdent = $filter('filter')($scope.MeasureTypes, {Ident: measureTypeIdent}, true)[0].EntitySearchDataTypeIdent;
                
                $scope.measure.DataTypeIdent = dataTypeIdent;

                $scope.HasDenominator(measureTypeIdent);

                if ($scope.ProjectQuestions1 && $scope.measure.Question1EntityProjectRequirementIdent > 0){
                    $scope.LoadProjectQuestions($scope.measure.EntityProject1Ident, 1, dataTypeIdent);
                };

                if (!$scope.measure.HasDenominator){

                    $scope.measure.EntityProject2Ident = 0;
                    $scope.measure.Question2EntityProjectRequirementIdent = 0;

                };

                // if we've selected count, the resource profile modal doesn't make sense, so mark as not selected
                if (measureTypeIdent == 6){

                    //Ident:3 = Resource Profile
                    $filter('filter')($scope.measure.Location, {MeasureLocationIdent: 3}, true)[0].Selected = false;

                };

            };

            // Check to see if current measure is a percentage
            $scope.HasDenominator = function (measureTypeIdent) {

                if (measureTypeIdent && $scope.MeasureTypes){
                    var type = $filter('filter')($scope.MeasureTypes, { Ident : measureTypeIdent}, true);

                    if (type && type.length > 0){
                        $scope.measure.HasDenominator = type[0].HasDenominator;
                    }
                    else {
                        $scope.measure.HasDenominator =  false;
                    }
                }
                else {
                    $scope.measure.HasDenominator =  false;
                }

            }; // HasDenominator


            // Save new dial
            $scope.SaveDial = function () {
                // If the Range form has been completely filled out...
                if ( !$scope.IsRangeFormInvalid() ) {
                    // If we're in edit mode
                    if ( $scope.isEditingRange ) {
                        // Update existing range
                        // Note: This will save the entire Measure
                        $scope.SaveRange(true);
                    }
                    else {
                        // Add a new range
                        $scope.AddRange(true);

                    }
                }
                else {
                    // Normal save
                    entityProjectMeasuresService.addEditDial($scope.measure).then(function (pl) {
                            $scope.DialModal.close();
                            $scope.reloadDials();
                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                }

            }; // save dial


            // delete dial
            $scope.DeleteDial = function () {

                entityProjectMeasuresService.deleteDial($scope.measure.Ident).then(function (pl) {
                        $scope.DialModal.close();
                        $scope.reloadDials();
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }; // DeleteDial

            // Close modal
            $scope.CancelDial = function() {
                $scope.DialModal.close();
                $scope.reloadDials();
            };

            // Open modal
            $scope.openModel = function(measure){

                if (measure){
                    $scope.measure = measure;
                } else {
                    $scope.measure = undefined;
                };

                $scope.getSegments();

                // Set up modal
                $scope.DialModal = $modal.open({
                    animation: true,
                    templateUrl: 'DialModal.html',
                    size: 'lg',
                    scope: $scope
                });

                $scope.initDialModal();

            };

            $scope.getSegments = function(){

                var getSavedSearches = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]) + "/" + 'GetEntitySearchByEntityIdent');

                getSavedSearches.then(function(pl) {
                        $scope.segments = pl.data.EntitySearch;

                        var segment = {Ident: 0, Name1: '(none)'};
                        $scope.segments.splice(0, 0, segment);
                        
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    });

            }; //getSegments


            // RANGES //

            // Check to see is the Add Range form is valid
            $scope.IsRangeFormInvalid = function () {
                // All fields are required
                if ( $scope.NewRange.Label == undefined || $scope.NewRange.Color == undefined || $scope.NewRange.Low == undefined || $scope.NewRange.High == undefined ) {
                    return true;
                }
                else if ( $scope.NewRange.Label == '' || $scope.NewRange.Color == '' || ($scope.NewRange.Low == 0 && $scope.NewRange.High == 0 )) {
                    return true;
                }
                else {
                    // If we have both ends of the range
                    if ( $scope.NewRange.Low != undefined &&  $scope.NewRange.Low != '' && $scope.NewRange.High != undefined && $scope.NewRange.High != '') {
                        var RangeStart = parseFloat($scope.NewRange.Low);
                        var RangeEnd = parseFloat($scope.NewRange.High);

                        // Make sure the high is greater than low
                        if ( RangeStart > RangeEnd) {
                            $scope.ShowRangeError = true;
                            return true;
                        }
                        else {
                            $scope.ShowRangeError = false;
                            return false;
                        }
                    }
                    else {
                        return false;
                    }
                }
            }; //IsRangeFormInvalid

            // Set range color
            $scope.PickColor = function(classname) {
                $scope.NewRange.Color = classname;
            };

            // Add new range
            $scope.AddRange = function (fullsave) {
                // Add new range to dial object
                $scope.measure.Ranges.push(angular.copy($scope.NewRange));

                if (fullsave) { 
                    // If full dial save, close modal and reload dials
                    // Send changes to server
                    entityProjectMeasuresService.addEditDial($scope.measure).then(function (pl) {
                            $scope.DialModal.close();
                            $scope.reloadDials();
                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                }; // if fullsave

                // Clear range form
                $scope.ClearRangeForm();
            }; //AddRange

            // For determining whether to show Add or Save button
            $scope.isEditingRange = false;
            
            // Edit existing range
            $scope.EditRange = function (range, index) {
                $scope.isEditingRange = true;

                $scope.NewRange.Ident = range.Ident;
                $scope.NewRange.Label = range.Label;
                $scope.NewRange.Color = range.Color;
                $scope.NewRange.Low = range.Low;
                $scope.NewRange.High = range.High;

                $scope.CurrentRangeIndex = index;
            };

            // Save existing range
            $scope.SaveRange = function (fullsave) {
                // Updated the range object
                $scope.measure.Ranges[$scope.CurrentRangeIndex].Label = $scope.NewRange.Label;
                $scope.measure.Ranges[$scope.CurrentRangeIndex].Color = $scope.NewRange.Color;
                $scope.measure.Ranges[$scope.CurrentRangeIndex].Low = $scope.NewRange.Low;
                $scope.measure.Ranges[$scope.CurrentRangeIndex].High = $scope.NewRange.High;

                if (!$scope.addMode) {
                    // Send changes to server
                    entityProjectMeasuresService.addEditDial($scope.measure).then(function (pl) {
                            // If full dial save, close modal and reload dials
                            if (fullsave) {
                                $scope.DialModal.close();
                            }
                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                }

                // Clear range form
                $scope.ClearRangeForm();
            }

            // Clear range form
            $scope.ClearRangeForm = function () {
                $scope.NewRange.Ident = undefined;
                $scope.NewRange.Label = undefined;
                $scope.NewRange.Color = undefined;
                $scope.NewRange.Low = undefined;
                $scope.NewRange.High = undefined;

                $scope.isEditingRange = false;
            }

            // Delete range
            $scope.DeleteRange = function (ident, index) {
                // Remove range from dial object
                $scope.measure.Ranges.splice(index, 1);

                // Clear range form if you had started editing the range then decided to delete it
                if ( $scope.NewRange.Ident == ident ) {
                    $scope.ClearRangeForm();
                }

                // Push changes to server so users don't have to press save
                if (!$scope.addMode) {
                    entityProjectMeasuresService.addEditDial($scope.measure).then(function (pl) {
                            // We're good
                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                }
            };

        } // controller

    };

});