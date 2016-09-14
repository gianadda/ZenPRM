'use strict'

angular
    .module('App.ProjectImportController', ["chart.js"])
    .controller('ProjectImportController', [
        '$scope',
        '$rootScope',
        '$filter',
        '$timeout',
        '$interval',
        '$global',
        'RESTService',
        'growl',
        'identity',
        'LookupTablesService',
        'MyProfileService',
        'ZenValidation',
        '$sce',
        '$stateParams',
        '$q',
        'entityProjectService',
        'entityNetworkService',
        function($scope, $rootScope, $filter, $timeout, $interval, $global, RESTService, growl, identity, LookupTablesService, MyProfileService, ZenValidation, $sce, $stateParams, $q, entityProjectService, entityNetworkService) {


            $scope.LookupTables = LookupTablesService;
            $scope.loadingPage = false;

            //setup navigation
            $rootScope.currentProjectIdent = $stateParams.ident;
            $rootScope.currentlySelectedProjectTab = 'Import';

            $scope.init = function() {

                $scope.HeadersProcessed = false;
                $scope.ImportLoading = false;

                // if we've changed projects clear the info
                if ($rootScope.CurrentProjectImport && !$rootScope.CurrentProjectImport.Started && $rootScope.CurrentProjectImport.Ident != $rootScope.currentProjectIdent){

                    $rootScope.CurrentProjectImport = {};

                };

                identity.identity().then(function() {
                    $scope.MyIdent = identity.getUserIdent();
                    MyProfileService.getProfile($scope.MyIdent).then(function(pl) {
                            $scope.CurrentEntity = pl;
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());

                        });


                        entityProjectService.getRequirementTypesForImport().then(function(data) {

                            $scope.RequirementTypes = data;

                        });


                }); // identity.identity

            }; // init

            // PROJECT IMPORT //

            //Find the Physician Upload holder so we can attach events
            $scope.ImportHolder = document.getElementById('ImportHolder');

            $scope.dropImportActive = false;
            $scope.FileToUpload;

            $scope.ImportHolder.ondragover = function(evt) {
                $scope.dropImportActive = true;
                evt.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
                $scope.$apply();
                return false;
            };
            $scope.ImportHolder.ondragleave = function() {
                $scope.dropImportActive = false;
                $scope.$apply();
                return false;
            };
            $scope.ImportHolder.ondragend = function() {
                $scope.dropImportActive = false;
                $scope.$apply();
                return false;
            };
            $scope.ImportHolder.ondrop = function(e) {
                $scope.FileToUpload = undefined;
                e.preventDefault();
                $scope.ImportLoading = true;
                $scope.$apply();
                if (e.dataTransfer.files.length == 1) {

                    $rootScope.CurrentProjectImport = {};
                    $rootScope.CurrentProjectImport.Ident = $stateParams.ident;
                    $rootScope.CurrentProjectImport.UseEmptyFieldsToClear = 'No';
                    $rootScope.CurrentProjectImport.AddEntities = 'Yes';
                    $rootScope.CurrentProjectImport.FileHeaders = [];
                    $rootScope.CurrentProjectImport.SuccessCount = 0;
                    $rootScope.CurrentProjectImport.FailureCount = 0;
                    $rootScope.CurrentProjectImport.Failures = [];
                    $scope.FileToUpload = e.dataTransfer.files[0];
                    $scope.processFileHeaders();
                }

            }

            $scope.processFileHeaders = function() {

                $rootScope.CurrentProjectImport.MappedFileHeaders = [];
                $rootScope.CurrentProjectImport.ProjectQuestions = $scope.formControls;

                Papa.parse($scope.FileToUpload, {
                    header: true,
                    worker: false,
                    dynamicTyping: false,
                    delimiter: ",",  // auto detect breaks once we introduce the delimited options within the question
                    error: function(err, file, inputElem, reason) {
                        console.log(err);
                    },
                    complete: function(results, file) {
                        $rootScope.CurrentProjectImport.FileHeaders = results.meta.fields;

                        $rootScope.CurrentProjectImport.FileHeaders.forEach(function(e, i) {

                            if (e.toUpperCase() == 'NPI') {
                                $rootScope.CurrentProjectImport.NPIFieldName = e;
                            } else if (e.toUpperCase() == 'DISPLAYNAME') {
                                $rootScope.CurrentProjectImport.FullNameFieldName = e;
                            } else if (e.toUpperCase() == 'IDENT') {
                                $rootScope.CurrentProjectImport.FullNameFieldName = e;
                                //Do Nothing
                            } else if (e.toUpperCase() == 'FULL NAME') {
                                $rootScope.CurrentProjectImport.FullNameFieldName = e;
                            } else if (e.toUpperCase() == 'FULLNAME') {
                                $rootScope.CurrentProjectImport.FullNameFieldName = e;
                            } else if (e.toUpperCase() == 'NAME') {
                                $rootScope.CurrentProjectImport.FullNameFieldName = e;
                            } else if (e.toUpperCase() == 'FIRST NAME') {
                                $rootScope.CurrentProjectImport.FirstNameFieldName = e;
                            } else if (e.toUpperCase() == 'FIRSTNAME') {
                                $rootScope.CurrentProjectImport.FirstNameFieldName = e;
                            } else if (e.toUpperCase() == 'LAST NAME') {
                                $rootScope.CurrentProjectImport.LastNameFieldName = e;
                            } else if (e.toUpperCase() == 'LASTNAME') {
                                $rootScope.CurrentProjectImport.LastNameFieldName = e;
                            } else {
                                var question = $filter('filter')($rootScope.CurrentProjectImport.ProjectQuestions, function(control) {
                                        var valid = false;
                                        if (control.RequiresAnswer == true && (control.label == e || $scope.EntityProject.Name1 + '-' + control.label == e)) {
                                            valid = true;
                                        }
                                        return valid;
                                    },
                                    true)


                                if (question.length > 0) {
                                    var myRequirementType = $filter('filter')($scope.RequirementTypes, { Ident: question[0].RequirementTypeIdent }, true);
                                    if (myRequirementType.length == 0) {
                                        question[0].CanAdd = false;
                                    }
                                }


                                if (question.length > 0) {
                                    $rootScope.CurrentProjectImport.MappedFileHeaders.push(question[0]);
                                } else {
                                    $rootScope.CurrentProjectImport.MappedFileHeaders.push({
                                        Ident: 0,
                                        label: e
                                    });
                                }

                            }

                        })

                        $scope.HeadersProcessed = true;
                        $scope.$apply();

                    }
                });
            }


            $scope.processFile = function() {

                $rootScope.CurrentProjectImport.Started = true;
                console.log('attempt');
                Papa.LocalChunkSize = 1024 * 512;
                var CurrentRowNumber = 0

                var arrAddingQuestions = [];

                //Loop through and add the questions, wait for it to finish...
                angular.forEach($scope.CurrentProjectImport.MappedFileHeaders, function(header) {
                    if (header.RequirementTypeIdent && header.RequirementTypeIdent !== 0 && header.Ident == 0) {
                        arrAddingQuestions.push($scope.createQuestion(header));
                    }

                })

                $q.all(arrAddingQuestions).then(function() {

                    //We need to call JSON.parse(JSON.stringify($scope.FileToUpload)) so that the file being  passed to the worker process doesn't habe any methods
                    Papa.parse($scope.FileToUpload, {
                        header: true,
                        worker: false,
                        dynamicTyping: false,
                        skipEmptyLines: true,
                        delimiter: ",",
                        error: function(err, file, inputElem, reason) {
                            console.log(err);

                            $scope.ImportLoading = false;
                            $rootScope.CurrentProjectImport.Started = false;
                            $scope.$apply();
                        },
                        complete: function(results, file) {

                            // remove this from the complete function as this fires prior to the API call completing
                            //$scope.LoadEntityProjectRequirements(false, true);
                            //$scope.ImportLoading = false;
                            //$rootScope.CurrentProjectImport.Started = false;
                            //$scope.$apply();
                        },
                        chunk: function(results, streamer, file) {
                            var postData = [];

                            angular.forEach(results.data, function(e, i) {
                                var localNPI = '';
                                var localFullName = '';
                                var localEntity;
                                var localData = {};
                                var tempEntities;

                                CurrentRowNumber += 1;

                                if ($rootScope.CurrentProjectImport.NPIFieldName) {

                                    localNPI = e[$rootScope.CurrentProjectImport.NPIFieldName].toString();
                                    tempEntities = $filter('filter')($scope.EntityNetwork, { NPI: localNPI }, true);
                                    if (localNPI != '' && tempEntities.length > 0) {
                                        localEntity = tempEntities[0];
                                    }
                                }

                                if ($rootScope.CurrentProjectImport.FullNameFieldName && !localEntity) {
                                    localFullName = e[$rootScope.CurrentProjectImport.FullNameFieldName];
                                    tempEntities = $filter('filter')($scope.EntityNetwork, { FullName: localFullName }, true);
                                    if (tempEntities.length == 1) {
                                        localEntity = tempEntities[0];
                                    }

                                }

                                if ($rootScope.CurrentProjectImport.FullNameFieldName && !localEntity) {
                                    localFullName = e[$rootScope.CurrentProjectImport.FullNameFieldName];
                                    tempEntities = $filter('filter')($scope.EntityNetwork, { DisplayName: localFullName }, true);
                                    if (tempEntities.length == 1) {
                                        localEntity = tempEntities[0];
                                    }

                                }

                                if ($rootScope.CurrentProjectImport.FirstNameFieldName && $rootScope.CurrentProjectImport.LastNameFieldName  && !localEntity) {
                                    localFullName = e[$rootScope.CurrentProjectImport.FirstNameFieldName] + " " + e[$rootScope.CurrentProjectImport.LastNameFieldName];
                                    tempEntities = $filter('filter')($scope.EntityNetwork, { FullName: localFullName }, true);
                                    if (tempEntities.length == 1) {
                                        localEntity = tempEntities[0];
                                    }

                                }

                                angular.forEach($rootScope.CurrentProjectImport.MappedFileHeaders, function(item, i) {

                                    if (item.RequirementTypeIdent == 9) {
                                        item.RequirementTypeIdent = 9;
                                    }
                                    var innerData = e[item.label];


                                    if (!angular.isDefined(innerData)) {
                                        innerData = e[$scope.EntityProject.Name1 + '-' + item.label];
                                    };

                                    if (angular.isDefined(innerData)) {


                                        if (innerData !== '' || $rootScope.CurrentProjectImport.UseEmptyFieldsToClear == 'Yes') {
                                            var myRequirementType = $filter('filter')($scope.RequirementTypes, { Ident: item.RequirementTypeIdent }, true);
                                            
                                            // yes/no
                                            if (myRequirementType.length > 0 && myRequirementType[0].EntitySearchDataTypeIdent == 5) {
                                                //Turn whatever they pass in into a bit, then turn that bit back to Y/N

                                                localData[item.Ident] = $scope.BooleanToSubmitableYesNo($scope.stringToBoolean(innerData));

                                            // numbers
                                            } else if (myRequirementType.length > 0 && myRequirementType[0].EntitySearchDataTypeIdent == 1) {
                                                
                                                localData[item.Ident] = parseFloat(innerData.replace(',', ''));

                                            // dates
                                            } else if (myRequirementType.length > 0 && myRequirementType[0].EntitySearchDataTypeIdent == 3) {
                                                
                                                localData[item.Ident] = moment(innerData).format('YYYY-MM-DD');

                                            // multi selects
                                            } else if (item.Delimiter){

                                                // if there is a delimter, we have to split the data and then pass it to the server
                                                localData[item.Ident] = $scope.StringArrayToJSONObject(innerData, item.Delimiter);

                                            } else {
                                                //Normal Case
                                                localData[item.Ident] = innerData;

                                            }

                                        }

                                    }; // if (angular.isDefined(innerData))
                                })

                                if (localEntity) {

                                    $rootScope.CurrentProjectImport.SuccessCount += 1;
                                    //Lookup RequirementIdent
                                    postData.push({
                                        EntityIdent: localEntity.EntityIdent,
                                        Data: localData
                                    })

                                } else {

                                    if ($rootScope.CurrentProjectImport.AddEntities == 'Yes' && localNPI !== '' && ZenValidation.ValidNPI(localNPI)) {

                                        $rootScope.CurrentProjectImport.SuccessCount += 1;

                                        postData.push({
                                            NPI: localNPI,
                                            Active: true,
                                            EntityIdent: 0,
                                            Data: localData
                                        })

                                    } else {

                                        var WhoWeCouldntFind = '';
                                        if ($rootScope.CurrentProjectImport.NPIFieldName) {
                                            WhoWeCouldntFind = e[$rootScope.CurrentProjectImport.NPIFieldName].toString();
                                        }
                                        if ($rootScope.CurrentProjectImport.FullNameFieldName) {
                                            if (WhoWeCouldntFind == '') {
                                                WhoWeCouldntFind = e[$rootScope.CurrentProjectImport.FullNameFieldName].toString();

                                            } else {

                                                WhoWeCouldntFind = WhoWeCouldntFind + ' ' + e[$rootScope.CurrentProjectImport.FullNameFieldName].toString();
                                            }


                                        };

                                        if ($rootScope.CurrentProjectImport.FirstNameFieldName && $rootScope.CurrentProjectImport.LastNameFieldName) {
                                            if (WhoWeCouldntFind == '') {
                                                WhoWeCouldntFind = e[$rootScope.CurrentProjectImport.FirstNameFieldName].toString() + ' ' + e[$rootScope.CurrentProjectImport.LastNameFieldName].toString();

                                            } else {

                                                WhoWeCouldntFind = WhoWeCouldntFind + ' ' + e[$rootScope.CurrentProjectImport.FirstNameFieldName].toString() + ' ' + e[$rootScope.CurrentProjectImport.LastNameFieldName].toString();;
                                            }

                                        };

                                        if (WhoWeCouldntFind.trim() == '') {
                                            WhoWeCouldntFind = '""'
                                        }
                                        $rootScope.CurrentProjectImport.Failures.push({
                                            ErrorText: "Line " + CurrentRowNumber.toString() + ': Could not find ' + WhoWeCouldntFind + ' or multiple matches occurred.'
                                        });

                                        $rootScope.CurrentProjectImport.FailureCount += 1;
                                    }
                                }


                            })
                            var postEntityProjectRequirements = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + "/Import", postData);

                            postEntityProjectRequirements.then(function(pl) {
                                    growl.success($global.GetRandomSuccessMessage());

                                    $scope.LoadEntityProjectRequirements(false, true);
                                    $scope.ImportLoading = false;
                                    $rootScope.CurrentProjectImport.Started = false;
                                    $scope.$apply();
                                },
                                function(errorPl) {

                                    growl.success($global.GetRandomErrorMessage());

                                    $scope.LoadEntityProjectRequirements(false, true);
                                    $scope.ImportLoading = false;
                                    $rootScope.CurrentProjectImport.Started = false;
                                    $scope.$apply();

                                });


                            console.log(results);
                        }
                    });

                });

            };

            $scope.StringArrayToJSONObject = function(string, delimiter){

                var answers = {};
                var array = string.split(delimiter);

                angular.forEach(array, function(value) {

                    value = value.trim();

                    answers[value] = true;

                });

                return answers;

            }; //StringArrayToJSONObject

            $scope.BooleanToSubmitableYesNo = function(bol) {
                if (bol) {
                    return "Yes";
                } else {
                    return "No";
                }
            }

            $scope.stringToBoolean = function(str) {

                if (typeof str === 'boolean') {
                    return str;
                }
                if (typeof str === 'number') {
                    str = str.toString();
                }

                switch (str.toLowerCase().trim()) {
                    case "true":
                    case "t":
                    case "yes":
                    case "y":
                    case "1":
                        return true;
                    case "false":
                    case "no":
                    case "n":
                    case "f":
                    case "0":
                    case null:
                        return false;
                    default:
                        return Boolean(str);
                }
            }

            $scope.createQuestion = function(header) {

                if (header.RequirementTypeIdent !== 0) {
                    var question = {
                        CreateToDoUponCompletion: false,
                        EntityProjectIdent: $rootScope.CurrentProjectImport.Ident,
                        HasOptions: false,
                        Ident: 0,
                        PercentComplete: "0.00",
                        RequirementTypeIdent: header.RequirementTypeIdent,
                        ToDoAssignee: "",
                        ToDoAssigneeEntityIdent: 0,
                        ToDoDesc1: "",
                        ToDoDueDateNoOfDays: 0,
                        ToDoTitle: "",
                        TotalEntityProjectEntityEntityProjectAnswers: 0,
                        TotalEntityProjectEntityEntityProjectRequirement: 0,
                        description: "",
                        helpText: "",
                        label: header.label,
                        model: 0,
                        options: "",
                        placeholder: "",
                        showEditAssignee: false,
                        sortOrder: 0,
                        type: ""
                    }


                    var postQuestion = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREQUIREMENT]), question);

                    return postQuestion.then(function(pl) {

                            header.Ident = pl.data;
                            //console.log($scope.CurrentProjectImport.MappedFileHeaders);

                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                }

            };

            $scope.downloadStarterFileWithData = function() {

                var objListOfColumns = {};
                objListOfColumns = [];
                objListOfColumns.push('NPI');
                objListOfColumns.push('DisplayName');
                angular.forEach($scope.formControls, function(control) {
                    if (control.RequiresAnswer == true) {
                        var myRequirementType = $filter('filter')($scope.RequirementTypes, { Ident: control.RequirementTypeIdent }, true);
                        if (myRequirementType.length !== 0) {
                            objListOfColumns.push($scope.EntityProject.Name1 + '-' + control.label);
                        }
                    }
                })

                $scope.searchCriteria = {};
                $scope.searchCriteria.keyword = '';
                $scope.searchCriteria.resultsShown = $scope.EntityProjectEntity.length;
                $scope.searchCriteria.searchGlobal = false;
                $scope.searchCriteria.location = '';
                $scope.searchCriteria.radius = 0;
                $scope.searchCriteria.latitude = 0.0;
                $scope.searchCriteria.longitude = 0.0;
                $scope.searchCriteria.addEntityIdents = '';
                $scope.searchCriteria.filters = [];

                var addFilter = {};
                addFilter.entitySearchFilterTypeIdent = 1; //Project Specific
                addFilter.entitySearchOperatorIdent = 1; //Entity Is On Project
                addFilter.entityProjectRequirementIdent = 0; //none needed
                addFilter.referenceIdent = $scope.EntityProject.Ident; //project Ident
                addFilter.searchValue = ''; //none needed

                $scope.searchCriteria.filters.push(addFilter);
                $scope.searchCriteria.fullProjectExport = true;

                //Fire a search and save the ident so that we can use it for the "EXPORT" link
                var postEntitySearch = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]), $scope.searchCriteria);
                var strData;
                postEntitySearch.then(function(pl, r) {

                    //$rootScope.entitySearchHistoryIdent = pl.data.ResultCounts[0].EntitySearchHistoryIdent;;

                    //strData = Papa.unparse(pl.data);
                    strData = Papa.unparse({
                        fields: objListOfColumns,
                        data: pl.data.Entities
                    })

                    setTimeout($scope.downloadStarterFileWithDataTimeout(strData, 3), 1);

                })


                /*      var ident = $rootScope.entitySearchHistoryIdent;

                      var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH, ident]);

                      return URI;*/

            };

            $scope.downloadStarterFileWithDataTimeout = function(BlobData, level) {

                var blob = new Blob([BlobData], { type: "application/csv;charset=utf-8;" });
                var filename = '';
                if (level == 1) {
                    filename = 'StarterFileHeadersOnly.csv';
                } else if (level == 2) {
                    filename = 'StarterFileHeadersAndParticipants.csv';
                } else if (level == 3) {
                    filename = 'StarterFileHeadersParticipantsAndData.csv';
                }

                saveAs(blob, filename);

            }


            $scope.downloadStarterFile = function(bolIncludeParticipants) {

                var objListOfColumns = {};
                objListOfColumns.fields = [];
                objListOfColumns.fields.push('NPI');
                objListOfColumns.fields.push('FullName');
                angular.forEach($scope.formControls, function(control) {
                    if (control.RequiresAnswer == true) {
                        var myRequirementType = $filter('filter')($scope.RequirementTypes, { Ident: control.RequirementTypeIdent }, true);
                        if (myRequirementType.length !== 0) {
                            objListOfColumns.fields.push($scope.EntityProject.Name1 + '-' + control.label);
                        }
                    }

                })

                var strData = Papa.unparse(objListOfColumns);

                if (bolIncludeParticipants) {

                    strData += Papa.unparse({
                        header: false,
                        fields: ["NPI", "FullName"],
                        data: $scope.EntityProjectEntity
                    }).replace('NPI,FullName', '')

                }

                if (bolIncludeParticipants) {
                    setTimeout($scope.downloadStarterFileWithDataTimeout(strData, 2), 1);

                } else {
                    setTimeout($scope.downloadStarterFileWithDataTimeout(strData, 1), 1);

                }

            }

            $scope.LoadEntityProjectRequirements = function(fireInit, fireReloadHeaders) {

                var searchCriteria = [{
                    name: "bolIncludeParticipants",
                    value: true
                }, {
                    name: "bolIncludeQuestions",
                    value: true
                }, {
                    name: "bolIncludeAnswerCount",
                    value: false
                }];

                var getEntityProjectRequirements = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTDETAILS]), searchCriteria, $stateParams.ident);

                getEntityProjectRequirements.then(function(pl) {

                    $scope.formControls = $filter('filter')(pl.data.EntityProjectRequirement, { RequiresAnswer: true }, true);

                    $scope.EntityProject = pl.data.EntityProject[0];
                    $scope.EntityProjectEntity = pl.data.EntityProjectEntity;

                    $scope.LoadEntityProjectExport();

                    if (fireInit) {
                        $timeout(function() {
                            //DOM has finished rendering
                            $scope.init();
                        });
                    }

                    if (fireReloadHeaders) {
                        $scope.processFileHeaders();
                    }

                    $rootScope.PageTitle = $scope.EntityProject.Name1 + ' - Import/Export';
                },
                function(errorPl) {
                    growl.error($global.GetRandomErrorMessage());
                });

                entityNetworkService.getEntityNetwork().then(function(data) {

                    $scope.EntityNetwork = data;

                });

            }; // LoadEntityProjectRequirements

            $scope.IsCustomer = function() {
                return $global.isCustomer();
            }

            // PROJECT EXPORT //

            $scope.ExportProject = function() {

                var postEntityProjectExport = RESTService.postAsChild(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), $scope.EntityProject.Ident, 'export');

                postEntityProjectExport.then(function(pl) {

                        $scope.LoadEntityProjectExport();
                        growl.success('The project has been queued and will be archived into a single zip file. Check the grid below to get a status update on the export process.');

                        //go refresh the project data until the file is done processing
                        $scope.checkExportProcess = $interval($scope.determineIfExportIsProcessing, 10000);

                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            };

            $scope.determineIfExportIsProcessing = function() {

                var getEntityProjectExport = RESTService.getAsChild(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), $scope.EntityProject.Ident, 'export');

                getEntityProjectExport.then(function(pl) {

                        $scope.EntityProjectExports = pl.data;

                        angular.forEach($scope.EntityProjectExports, function(value,key){

                            value.exportLink = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTEXPORT, value.Ident]);

                        });

                        var processing = $filter('filter')($scope.EntityProjectExports, {
                            Processing: true
                        }, true);

                        if (processing.length === 0) {
                            growl.success('The project file has finished exporting! Please click download to retrieve your file.');
                            $interval.cancel($scope.checkExportProcess);
                        };

                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            };

            $scope.LoadEntityProjectExport = function() {

                var getEntityProjectExport = RESTService.getAsChild(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), $scope.EntityProject.Ident, 'export');

                getEntityProjectExport.then(function(pl) {
                        $scope.EntityProjectExports = pl.data;

                        angular.forEach($scope.EntityProjectExports, function(value,key){

                            value.exportLink = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTEXPORT, value.Ident]);

                        });
                        
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            };

            // Load answers
            $scope.LoadEntityProjectRequirements(true, false);
        }
    ]);
