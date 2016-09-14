'use strict'

angular
    .module('App.ProjectController', [])
    .controller('ProjectController', [
        '$scope',
        '$rootScope',
        '$log',
        '$filter',
        '$timeout',
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
        'ZenValidation',
        function($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, growl, $window, identity, LookupTablesService, MyProfileService, $sce, $state, $stateParams, ZenValidation) {

            $rootScope.CurrentProfileEntityIdent = $stateParams.entityIdent;
            $rootScope.PreviewMode = !angular.isDefined($stateParams.entityIdent);
            $scope.ZenValidation = ZenValidation;
            $scope.LookupTables = LookupTablesService;
            $rootScope.EntityLoaded = true;
            $scope.formSchema = {};
            $scope.formControls = [];
            $scope.loading = true;
            $scope.AllowSave = true;
            $scope.projectIdent = $stateParams.ident;


            $scope.init = function() {

                MyProfileService.getProfile($stateParams.entityIdent).then(function(pl) {
                        $scope.EntityDetails = pl.Entity[0];
                        console.log($scope.EntityDetails);
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

                // Load questions
                $scope.LoadEntityProjectRequirements();

            }


            $scope.IsCustomer = function() {
                return $global.isCustomer();
            }


            $scope.getFileLink = function(answerIdent, thumbnail) {

                var ident = 0;

                if ($stateParams.entityIdent) {
                    ident = $stateParams.entityIdent
                } else {
                    ident = identity.getUserIdent();
                };

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITY, ident, $global.RESTControllerNames.FILES, answerIdent]);

                if (thumbnail) {

                    URI = URI + '?thumbnail=true'

                };

                return URI;

            };


            $scope.HasError = function(form, value, controlName, type) {

                if (type == 'validator') {
                    //return $scope.ZenValidation.ValidAlphaNumeric(form[controlName].$viewValue);
                    return !!form[controlName].$error.validator;
                } else if (type == 'pristine') {
                    return !!!form[controlName].$pristine;
                } else {
                    return !!form[controlName].$error.maxlength;
                }

            }


            $scope.SelectAll = function(model, options, formSchema, truthy) {
                var myModel = model;
                if (!formSchema[myModel]) {
                    formSchema[myModel] = {};
                }
                angular.forEach(options, function(value, key) {
                    formSchema[myModel][value] = truthy;
                })

                if ($scope.ProjectForm) {

                    $scope.ProjectForm.$dirty = true; // make sure the form is updated to changed so we can save

                };

            }


            $scope.TrustEmailHTML = function(email) {
                return $sce.trustAsHtml(email);
            };


            $scope.LoadEntityProjectRequirements = function() {

                var getEntityProjectRequirements;

                if ($stateParams.entityIdent) {
                    getEntityProjectRequirements = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + "/" + $stateParams.ident + "/" + $stateParams.entityIdent);
                } else {
                    getEntityProjectRequirements = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), $stateParams.ident);
                }

                getEntityProjectRequirements.then(function(pl) {

                        if (pl.data) {

                            angular.forEach(pl.data.EntityProjectRequirement, function(value, key) {

                                if (value.values) {

                                    if (value.type.indexOf('ZenCheckboxList') >= 0) {

                                        $scope.formSchema[value.Ident.toString()] = JSON.parse('{' + value.values + '}');
                                        var outterKey = value.Ident.toString();
                                        angular.forEach($scope.formSchema[outterKey], function(innerValue, innerKey) {
                                            $scope.formSchema[outterKey][innerKey] = (innerValue === 'True');
                                        })


                                    } else if (value.type.indexOf('ZenTags') >= 0) {

                                        $scope.formSchema[value.Ident.toString()] = JSON.parse('[' + value.values + ']');

                                    } else if (value.type.indexOf('ZenAddress') >= 0) {

                                        $scope.formSchema[value.Ident.toString()] = JSON.parse('{' + value.values + '}');
                                        //Fix the State ident to be an int
                                        $scope.formSchema[value.Ident.toString()].State = parseInt($scope.formSchema[value.Ident.toString()].StateName);

                                    } else if (value.type.indexOf('ZenHours') >= 0) {

                                        $scope.formSchema[value.Ident.toString()] = JSON.parse('{' + value.values + '}');

                                        $scope.formSchema[value.Ident.toString()].SundayStartTime = moment(new Date($scope.formSchema[value.Ident.toString()].SundayStartTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].SundayEndTime = moment(new Date($scope.formSchema[value.Ident.toString()].SundayEndTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].SundayClosed = ($scope.formSchema[value.Ident.toString()].SundayClosed === 'True');

                                        $scope.formSchema[value.Ident.toString()].MondayStartTime = moment(new Date($scope.formSchema[value.Ident.toString()].MondayStartTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].MondayEndTime = moment(new Date($scope.formSchema[value.Ident.toString()].MondayEndTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].MondayClosed = ($scope.formSchema[value.Ident.toString()].MondayClosed === 'True');

                                        $scope.formSchema[value.Ident.toString()].TuesdayStartTime = moment(new Date($scope.formSchema[value.Ident.toString()].TuesdayStartTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].TuesdayEndTime = moment(new Date($scope.formSchema[value.Ident.toString()].TuesdayEndTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].TuesdayClosed = ($scope.formSchema[value.Ident.toString()].TuesdayClosed === 'True');

                                        $scope.formSchema[value.Ident.toString()].WednesdayStartTime = moment(new Date($scope.formSchema[value.Ident.toString()].WednesdayStartTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].WednesdayEndTime = moment(new Date($scope.formSchema[value.Ident.toString()].WednesdayEndTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].WednesdayClosed = ($scope.formSchema[value.Ident.toString()].WednesdayClosed === 'True');

                                        $scope.formSchema[value.Ident.toString()].ThursdayStartTime = moment(new Date($scope.formSchema[value.Ident.toString()].ThursdayStartTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].ThursdayEndTime = moment(new Date($scope.formSchema[value.Ident.toString()].ThursdayEndTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].ThursdayClosed = ($scope.formSchema[value.Ident.toString()].ThursdayClosed === 'True');

                                        $scope.formSchema[value.Ident.toString()].FridayStartTime = moment(new Date($scope.formSchema[value.Ident.toString()].FridayStartTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].FridayEndTime = moment(new Date($scope.formSchema[value.Ident.toString()].FridayEndTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].FridayClosed = ($scope.formSchema[value.Ident.toString()].FridayClosed === 'True');

                                        $scope.formSchema[value.Ident.toString()].SaturdayStartTime = moment(new Date($scope.formSchema[value.Ident.toString()].SaturdayStartTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].SaturdayEndTime = moment(new Date($scope.formSchema[value.Ident.toString()].SaturdayEndTime)).toDate();
                                        $scope.formSchema[value.Ident.toString()].SaturdayClosed = ($scope.formSchema[value.Ident.toString()].SaturdayClosed === 'True');


                                    } else if (value.type.indexOf('ZenSingleLineDateTextBox') >= 0 || value.type.indexOf('ZenSingleLineDateTimeTextBox') >= 0) {

                                        //$scope.formSchema[value.Ident.toString()] = $filter('date')(new Date(value.values.substring(0,10)), 'yyyy-MM-dd 00:00:00 Z');
                                        //$scope.formSchema[value.Ident.toString()] = value.values.substring(0, 10);
                                        $scope.formSchema[value.Ident.toString()] = value.values;

                                    } else if (value.type.indexOf('ZenNumberPicker') >= 0 || value.type.indexOf('ZenCurrency') >= 0 || value.type.indexOf('ZenSlider') >= 0) {

                                        $scope.formSchema[value.Ident.toString()] = parseFloat(value.values);

                                    } else if (value.type.indexOf('ZenImageUpload') >= 0) {

                                        $scope.formSchema[value.Ident.toString()] = JSON.parse('{' + value.values + '}');

                                    } else if (value.type.indexOf('ZenFileUpload') >= 0) {

                                        $scope.formSchema[value.Ident.toString()] = JSON.parse('{' + value.values + '}');

                                    } else {

                                        $scope.formSchema[value.Ident.toString()] = value.values;

                                    }

                                }

                                if (value.options) {
                                    value.options = value.options.split('|');
                                }

                            });


                            $scope.formControls = pl.data.EntityProjectRequirement;
                            $scope.EntityProject = pl.data.EntityProject[0];

                            console.log($scope.EntityProject);

                            if ($scope.IsCustomer() || !$scope.EntityProject.Archived) {
                                $scope.AllowSave = true;
                            } else {
                                $scope.AllowSave = false;
                            };

                            $scope.loading = false;

                            $timeout(function() {
                                //DOM has finished rendering

                                FileUploads();
                            });

                            $rootScope.PageTitle = $scope.EntityDetails.FullName + ' - ' + $scope.EntityProject.Name1;

                        }
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            };


            var FileUploads = function() {

                // Handle file uploads
                angular.forEach($scope.formControls, function(value, key) {
                    
                    if (value.type == 'ZenImageUpload' || value.type == 'ZenFileUpload') {
                        
                        var ImageUpload = document.getElementById(value.model);
                        //Find the Physician Upload holder so we can attach events

                        value.ImportLoading = false;
                        value.dropImportActive = false;

                        ImageUpload.ondragover = function(e) {
                            var elementID = this.id;
                            if (!this.classList.contains("active") && !$rootScope.PreviewMode) {
                                angular.forEach($scope.formControls, function(value, key) {
                                    if (value.model == elementID) {
                                        value.dropImportActive = true;
                                        $scope.$apply();
                                    }
                                });
                            }
                            return false;
                        };
                        ImageUpload.ondragleave = function(e) {
                            var elementID = this.id;
                            if (this.classList.contains("active")) {
                                angular.forEach($scope.formControls, function(value, key) {
                                    if (value.model == elementID) {

                                        value.dropImportActive = false;
                                        $scope.$apply();
                                    }
                                });
                            }
                            return false;
                        };
                        ImageUpload.ondragend = function(e) {
                            var elementID = this.id;
                            if (this.classList.contains("active")) {
                                angular.forEach($scope.formControls, function(value, key) {
                                    if (value.model == elementID) {

                                        value.dropImportActive = false;
                                        $scope.$apply();
                                    }
                                });
                            }
                            return false;
                        };
                        ImageUpload.ondrop = function(e) {
                            if (!$rootScope.PreviewMode) {
                                var elementID = this.id;
                                angular.forEach($scope.formControls, function(value, key) {
                                    if (value.model == elementID) {

                                        value.ImportLoading = true;
                                        value.dropImportActive = false;
                                        $scope.$apply();

                                        if (e.dataTransfer.files.length > 0) {

                                            var file = e.dataTransfer.files[0];
                                            
                                            // check the file size, if it is too large, we wont save it and will report back an error instead
                                            // right now, cap at 10 MB
                                            if (file.size <= 10485760){

                                                var reader = new FileReader();

                                                //Setup the "onload" even to fire after the file is read into memory
                                                reader.onload = function(event) {
                                                    value.ImportLoading = false;
                                                    var binaryString = event.target.result;

                                                    if ($scope.ProjectForm) {

                                                        $scope.ProjectForm.$dirty = true; // make sure the form is updated to changed so we can save

                                                    };

                                                    $scope.formSchema[value.model] = {
                                                        FileName: file.name,
                                                        FileSize: file.size,
                                                        MimeType: file.type,
                                                        FileContents: binaryString,
                                                        FileKey: ""
                                                    };
                                                    $scope.$apply();
                                                };

                                                //Read the file.
                                                //reader.readAsText(e.dataTransfer.files[0]);
                                                reader.readAsDataURL(file);


                                            } else {

                                                growl.error('The file you are attempting to upload exceeds the maximum file upload size! The file upload limit is 10 MB.');
                                                value.ImportLoading = false;

                                            };

                                        }

                                    }
                                });
                            }
                            e.preventDefault();
                        } // ondrop

                    } // if

                }); // forEach

            } // init


            $rootScope.Save = function() {

                // check if the form has been changed, if not, then dont call to the db
                if ($scope.ProjectForm.$dirty) {

                    var postData = angular.copy($scope.formSchema);

                    angular.forEach(postData, function(value, key) {
                            if (angular.isDate(value)) {
                                postData[key] = $filter('date')(new Date(value), 'yyyy-MM-dd 00:00:00 Z');
                            }
                            if (value) {
                                if (value.EndTime) {
                                    if (angular.isDate(value.EndTime)) {
                                        postData[key].EndTime = $filter('date')(new Date(value.EndTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.StartTime) {
                                    if (angular.isDate(value.StartTime)) {
                                        postData[key].StartTime = $filter('date')(new Date(value.StartTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.SundayStartTime) {
                                    if (angular.isDate(value.SundayStartTime)) {
                                        postData[key].SundayStartTime = $filter('date')(new Date(value.SundayStartTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.SundayEndTime) {
                                    if (angular.isDate(value.SundayEndTime)) {
                                        postData[key].SundayEndTime = $filter('date')(new Date(value.SundayEndTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.MondayStartTime) {
                                    if (angular.isDate(value.MondayStartTime)) {
                                        postData[key].MondayStartTime = $filter('date')(new Date(value.MondayStartTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.MondayEndTime) {
                                    if (angular.isDate(value.MondayEndTime)) {
                                        postData[key].MondayEndTime = $filter('date')(new Date(value.MondayEndTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.TuesdayStartTime) {
                                    if (angular.isDate(value.TuesdayStartTime)) {
                                        postData[key].TuesdayStartTime = $filter('date')(new Date(value.TuesdayStartTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.TuesdayEndTime) {
                                    if (angular.isDate(value.TuesdayEndTime)) {
                                        postData[key].TuesdayEndTime = $filter('date')(new Date(value.TuesdayEndTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.WednesdayStartTime) {
                                    if (angular.isDate(value.WednesdayStartTime)) {
                                        postData[key].WednesdayStartTime = $filter('date')(new Date(value.WednesdayStartTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.WednesdayEndTime) {
                                    if (angular.isDate(value.WednesdayEndTime)) {
                                        postData[key].WednesdayEndTime = $filter('date')(new Date(value.WednesdayEndTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.ThursdayStartTime) {
                                    if (angular.isDate(value.ThursdayStartTime)) {
                                        postData[key].ThursdayStartTime = $filter('date')(new Date(value.ThursdayStartTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.ThursdayEndTime) {
                                    if (angular.isDate(value.ThursdayEndTime)) {
                                        postData[key].ThursdayEndTime = $filter('date')(new Date(value.ThursdayEndTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.FridayStartTime) {
                                    if (angular.isDate(value.FridayStartTime)) {
                                        postData[key].FridayStartTime = $filter('date')(new Date(value.FridayStartTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.FridayEndTime) {
                                    if (angular.isDate(value.FridayEndTime)) {
                                        postData[key].FridayEndTime = $filter('date')(new Date(value.FridayEndTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.SaturdayStartTime) {
                                    if (angular.isDate(value.SaturdayStartTime)) {
                                        postData[key].SaturdayStartTime = $filter('date')(new Date(value.SaturdayStartTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                                if (value.SaturdayEndTime) {
                                    if (angular.isDate(value.SaturdayEndTime)) {
                                        postData[key].SaturdayEndTime = $filter('date')(new Date(value.SaturdayEndTime), 'yyyy-MM-dd HH:mm:ss Z');
                                    };
                                };
                            }; // if (value)
                        }) //angular.forEach

                    //var postEntityProjectRequirements = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), postData);

                    // console.log($scope.EntityProject);

                    if ($scope.EntityProject.EntityIdent) {

                        //If we already have an Entity Ident on the project submission, add it to the querystring.
                        var postEntityProjectRequirements = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + "/" + $scope.EntityProject.EntityIdent, postData);

                    };

                    postEntityProjectRequirements.then(function(pl) {

                            // if the user is a customer, they should remain on this page
                            if ($scope.IsCustomer()){

                                $scope.LoadEntityProjectRequirements();
                                growl.success($global.GetRandomSuccessMessage());

                            } else {

                                // but if its a participant we should take them back to they projects page
                                growl.success('Success! Thanks for submitting your data!');
                                $state.go('site.Profile', {ident: $scope.EntityProject.EntityIdent});

                            };

                        },
                        function(errorPl) {

                            // if we get back and error type of 415, it means we tried to upload a bad file
                            if (errorPl.status == 415){

                                growl.error('The file type you are trying to upload is not allowed. To see the list of accepted file types, please click the Help link in the bottom right corner.', {ttl: 10000});

                                $scope.LoadEntityProjectRequirements();
                                
                            } else {

                                growl.error($global.GetRandomErrorMessage());

                            };

                            
                        });


                }; // if is dirty

            }; // save


            $scope.clearAnswer = function(control, index) {
                delete $scope.formSchema[control.model];
                control.submitted = false;

                var postData = {
                    EntityProjectRequirementIdent: control.Ident,
                    EntityIdent: $scope.EntityProject.EntityIdent
                }

                var deleteEntityProjectRequirement = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + "/ClearEntityProjectEntityAnswerValue", postData);

                deleteEntityProjectRequirement.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }; // clear Answer


            $scope.removeTypeaheadValueOnBackspace = function(event, formControl) {

                // if delete or backspace is entered
                if (event.keyCode === 8 || event.keyCode === 46) {
                    $scope.formSchema[formControl.model] = "";
                    formControl.submitted = false;
                    $scope.ProjectForm.$dirty = true;
                };
            };


            $scope.ShowHistory = false;
            $scope.GetQuestionHistory = function(formControl) {

                var ident;

                if ($rootScope.CurrentProfileEntityIdent) {
                    ident = $rootScope.CurrentProfileEntityIdent
                } else {
                    ident = identity.getUserIdent();
                };

                if (formControl.ShowingHistory == true) {
                    formControl.ShowingHistory = false;
                } else {
                    var params = [{
                        name: "resultsShown",
                        value: 25
                    }];

                    // Get data from API
                    var getQuestionHistoryData = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + '/' + $scope.projectIdent + '/entity/' + ident + '/history/' + formControl.Ident, params);

                    getQuestionHistoryData.then(function(pl) {
                            $scope.QuestionHistoryData = pl.data;

                            formControl.History = $scope.QuestionHistoryData;
                            formControl.ShowingHistory = true;
                            return formControl;
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                }
            }; //GetQuestionHistory


            $scope.saveAndClose = function(){

                // when selecting a file from the repo, save the project then close the modal (if necessary), then navigate
                $rootScope.Save();

                $scope.closeAnswerModal();

            };


            $scope.closeAnswerModal = function() {

                // if the answermodal is in scope, close it, otherwise it will be displayed and empty on the repo screen
                if ($rootScope.AnswerModal) {

                    $rootScope.AnswerModal.close();

                };

            };


            // Format datetime
            $scope.FormatDateTime = function(date) {
                if (moment(date).isValid()) {
                    return moment(date).format('YYYY-MM-DD h:mm:ss A');
                } else {
                    return date;
                }
            };


            $scope.init();

        }
    ]);
