'use strict'

angular
    .module('App.ProjectQuestionsController', ['as.sortable', 'textAngular'])
    .controller('ProjectQuestionsController', [
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
        '$sce',
        '$stateParams',
        '$modal',
        '$location',
        '$anchorScroll',
        'MyProfileService',
        '$q',
        function($scope, $rootScope, $log, $filter, $timeout, $interval, $http, $global, RESTService, growl, $window, identity, $sce, $stateParams, $modal, $location, $anchorScroll, MyProfileService, $q) {

            //setup navigation
            $rootScope.currentProjectIdent = $stateParams.ident;
            $rootScope.currentlySelectedProjectTab = 'Questions';
            $scope.activeQuestionIndex = -1;
            $scope.loading = true;
            $scope.loadingQuestionRecord = false;
            $scope.loadingEntities = false;

            // For various calculations
            var formBuilderHeight, windowHeight, windowWidth, headerHeight, containerElm, containerPadding, panelElm, panelBorder, panelHeading;

            // Customize WYSIWYG toolbar
            $scope.CustomToolbar = [
                ['p', 'ul', 'ol'],
                ['bold', 'italics', 'strikeThrough'],
                ['justifyLeft', 'justifyCenter', 'justifyRight', 'indent', 'outdent'],
                ['insertImage', 'insertLink', 'insertVideo'],
                ['redo', 'undo', 'clear', 'html']
            ];

            // Question options drag options
            $scope.dragControlListeners = {
                containment: '#sortable-container',
                clone: false,
                allowDuplicates: false
            };

            // Question drag options
            $scope.dragControlListeners2 = {
                containment: '#sortable-container-questions',
                containerPositioning: 'relative',
                clone: false,
                allowDuplicates: false,
                longTouch: true,
                // Scroll panel on drag as needed
                dragMove: function(pos, containment, event) {

                    var questionPos = pos.lastY;

                    // Desktop
                    // Need to scroll #SuperList
                    if (windowWidth >= 992) {
                        // scroll down
                        if (pos.lastDirY == 1) {
                            // Start scrolling when drag item is in bottom portion of form builder
                            if (questionPos >= (formBuilderHeight - 200)) {
                                panelElm.scrollTop = panelElm.scrollTop + 15;
                            }
                        }
                        // scroll up
                        else if (pos.lastDirY == -1) {
                            if (panelElm.scrollTop > 0) {
                                if (panelElm.scrollTop - 15 < 0) {
                                    panelElm.scrollTop = 0;
                                } else {
                                    panelElm.scrollTop = panelElm.scrollTop - 15;
                                }
                            }
                        }
                    }
                    // Mobile
                    // Need to scroll window
                    else {
                        // scroll down
                        if (pos.lastDirY == 1) {
                            // Start scrolling when drag item is in bottom portion of viewport
                            if (questionPos >= (windowHeight - 200)) {
                                window.scrollTo(0, window.scrollY + 15);
                            }
                        }
                        // scroll up
                        else if (pos.lastDirY == -1) {
                            if (window.scrollY > 0) {
                                if (window.scrollY - 15 < 0) {
                                    window.scrollTo(0, 0);
                                } else {
                                    window.scrollTo(0, window.scrollY - 15);
                                }
                            }
                        }
                    }
                },
                orderChanged: function(event) {

                    //set the new row position to be highlighted
                    $scope.activeQuestionIndex = event.dest.index;

                    angular.forEach($scope.EntityProjectQuestions, function(value, key) {
                        $scope.EntityProjectQuestions[key].sortOrder = (key + 1);
                    });

                    // now that all the orders are updated, save them to the db
                    var putAllQuestion = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREQUIREMENT]), $scope.EntityProjectQuestions);

                    putAllQuestion.then(function(pl) {
                            // Done!
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });

                }
            };


            // Handle form buidler sizing and toggle icon on browser resize
            window.onresize = function() {
                setHeight();
                UpdateToggleIcon();
            }


            $scope.init = function(activeQuestionIndex, initialLoad) {

                // only need to call this once
                if (initialLoad) {

                    MyProfileService.getMyProfile().then(function(pl) {
                        $scope.Profile = pl;
                    });

                };

                var searchCriteria = [{
                    name: "bolIncludeQuestions",
                    value: true
                }];

                var getEntityProjectRequirements = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTDETAILS]), searchCriteria, $stateParams.ident);

                getEntityProjectRequirements.then(function(pl) {

                    $scope.EntityProject = pl.data.EntityProject[0];
                    $scope.EntityProjectQuestions = pl.data.EntityProjectRequirement;

                    $scope.activeQuestionIndex = activeQuestionIndex;

                    // since this is initial load we need to setup the state of the first question

                    $scope.activateQuestionRow($scope.EntityProjectQuestions[activeQuestionIndex], $scope.activeQuestionIndex, true);

                    $scope.loading = false;

                    $rootScope.PageTitle = $scope.EntityProject.Name1 + ' - Questions';

                });

                var getRequirementType = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.REQUIREMENTTYPE]));

                getRequirementType.then(function(pl) {

                    $scope.RequirementTypes = pl.data;

                    $scope.loading = false;

                });

                // Set height calculation variables after DOM has loaded
                // Avoid hard-coded values because of differences between mobile and desktop views
                $timeout(function() {
                    headerHeight = $window.document.getElementById('Title').offsetHeight;
                    containerElm = $window.document.getElementById('FormBuilder');
                    containerPadding = $window.getComputedStyle(containerElm, null).getPropertyValue('padding-top');
                    containerPadding = 2 * parseInt(containerPadding.substr(0, 2));
                    panelElm = $window.document.getElementById('SuperList');
                    panelBorder = 2; // this never changes
                    panelHeading = $window.document.getElementById('TitleBar').offsetHeight;

                    // Set #FormBuilder height
                    setHeight();

                    // Hide sidebar on mobile devices by default
                    if (windowWidth < 992) {
                        $scope.ToggleSidebar(false, true);
                    } else {
                        $scope.ToggleSidebar(true, true);
                    }
                }, 0);

            }; // init


            // Set panel height
            function setHeight() {

                // Always do calculations so we can use it elsewhere
                windowHeight = window.innerHeight;
                windowWidth = window.innerWidth;
                formBuilderHeight = windowHeight - headerHeight - containerPadding - panelBorder - panelHeading;

                if (windowWidth >= 992) {
                    document.getElementById('SuperList').style.height = formBuilderHeight + 'px';
                }

            }


            // Highlight selected row and load data
            $scope.activateQuestionRow = function(question, index, initialLoad) {

                $scope.loadingQuestionRecord = true;

                //This means I'm changing records and not empty
                if ((index !== $scope.activeQuestionIndex) || initialLoad) {

                    // Set the 'active' class
                    $scope.activeQuestionIndex = index;

                    if (question) {
                        question.questionOptions = [];
                    };


                    if (question && question.options && question.options.length > 0) {

                        var items = question.options.split('|');

                        angular.forEach(items, function(value, key) {

                            question.questionOptions.push(value);
                        });

                        // if its a rating, setup the max and min values
                        if (question.RequirementTypeIdent == 28) {

                            question.minRange = Math.min.apply(Math, question.questionOptions);
                            question.maxRange = Math.max.apply(Math, question.questionOptions);


                        };

                        $scope.requirementType = question.RequirementTypeIdent;

                    } // if questions.options

                }

                $timeout(function() {
                    $scope.loadingQuestionRecord = false;
                }, 200);

            };

            // Show/hide edit panel
            $scope.ToggleSidebar = function(show, initialLoad) {

                // Explicitly show
                if (show) {
                    $scope.showSidebar = true;
                }
                // Explicitly hide
                else if (!show) {
                    $scope.showSidebar = false;
                }

                UpdateToggleIcon(initialLoad);

            }


            // Update toggle icon
            var UpdateToggleIcon = function(initialLoad) {

                // Wrap in $timeout to ensure DOM gets updated
                $timeout.cancel(timeoutPromise);
                var timeoutPromise = $timeout(function() {
                    // Desktop
                    if (windowWidth >= 992) {
                        if ($scope.showSidebar) {
                            $scope.SidebarArrowClass = 'fa-caret-square-o-right';
                        } else {
                            $scope.SidebarArrowClass = 'fa-caret-square-o-left';
                        }
                    }
                    // Mobile
                    else {
                        if ($scope.showSidebar) {
                            $scope.SidebarArrowClass = 'fa-caret-square-o-up';
                        } else {
                            $scope.SidebarArrowClass = 'fa-caret-square-o-down';
                        }
                    }
                }, 0);

            }


            $scope.removeOptionValue = function(question, index) {

                question.questionOptions.splice(index, 1);

            };


            $scope.addOption = function(question) {

                question.questionOptions.push('');

            };


            $scope.setToDoDefaultAssignment = function(question) {

                if (question.CreateToDoUponCompletion && !question.ToDoAssigneeEntityIdent) {

                    question.ToDoAssigneeEntityIdent = identity.getUserIdent();
                    question.ToDoAssignee = identity.getUserName();

                };

            };


            $scope.saveQuestion = function(question, autoSave) {

                var optionString = '';
                var i;

                // if its a rating, convert the min and max to an options string
                if (question.RequirementTypeIdent == 28) {

                    for (i = question.minRange; i <= question.maxRange; i++) {
                        optionString = optionString + i + '|';
                    };

                } else {

                    angular.forEach(question.questionOptions, function(value, key) {

                        if (value) {

                            optionString = optionString + value + '|';
                        }

                    });


                }; //if (question.RequirementTypeIdent == 28)


                //remove the trailing pipe from the string
                question.options = optionString.slice(0, -1);

                if (question.Ident > 0) {

                    var putQuestion = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREQUIREMENT]), question.Ident, question);

                    putQuestion.then(function(pl) {

                            $scope.init($scope.activeQuestionIndex, false);

                            if (!autoSave) {
                                growl.success($global.GetRandomSuccessMessage());
                            };

                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });

                } else {

                    var postQuestion = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREQUIREMENT]), question);

                    postQuestion.then(function(pl) {

                            // return the new Ident and add to the object so any future edits are puts instead of post
                            $scope.init($scope.activeQuestionIndex, false);

                            growl.success($global.GetRandomSuccessMessage());

                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });


                };

            };


            $scope.addQuestion = function() {

                var index;
                var sortOrder;

                // if there are already other questions, then inject the sort order after the selected question
                if ($scope.EntityProjectQuestions.length > 0) {
                    sortOrder = $scope.EntityProjectQuestions[$scope.activeQuestionIndex].sortOrder + 1;
                    index = ($scope.activeQuestionIndex + 1)
                } else {
                    sortOrder = 1; // otherwise default to 1
                    index = 0;
                };

                var question = {
                    Ident: 0,
                    model: 0,
                    EntityProjectIdent: $rootScope.currentProjectIdent,
                    label: '',
                    options: '',
                    placeholder: '',
                    helpText: '',
                    PercentComplete: '0.00',
                    RequirementTypeIdent: 0,
                    TotalEntityProjectEntityEntityProjectAnswers: 0,
                    TotalEntityProjectEntityEntityProjectRequirement: 0,
                    description: '',
                    HasOptions: false,
                    sortOrder: sortOrder,
                    type: '',
                    CreateToDoUponCompletion: false,
                    ToDoTitle: '',
                    ToDoDesc1: '',
                    ToDoAssigneeEntityIdent: 0,
                    ToDoAssignee: '',
                    ToDoDueDateNoOfDays: 0,
                    showEditAssignee: false,
                    questionOptions: []
                };

                var hash = 'question' + index;

                $scope.EntityProjectQuestions.splice(index, 0, question);

                $scope.ToggleSidebar(true);

                // Scroll to new question if not visible
                var questionElm = $window.document.getElementById('question' + index);

                //need to check element otherwise error occurs if it hasn't been added yet
                if (questionElm && (questionElm.offsetTop > (panelElm.scrollTop + formBuilderHeight) || questionElm.offsetTop < panelElm.scrollTop)) {
                    $location.hash(hash);
                    $anchorScroll();
                } else if (!questionElm) { // if the element doesnt exist yet, scroll to it automatically
                    $location.hash(hash);
                    $anchorScroll();
                }

                $scope.activeQuestionIndex = index;

            };


            $scope.checkIfRequirementTypeHasOptions = function(question) {

                var ident = question.RequirementTypeIdent;

                var selected = $filter('filter')($scope.RequirementTypes, {
                    Ident: ident
                }, true);

                if (selected) {

                    question.HasOptions = selected[0].HasOptions;

                };


            };

            $scope.isQuestionValidForSave = function(question) {

                if (question.RequirementTypeIdent == 0) {

                    return false;

                } else if (question.RequirementTypeIdent == 28) {

                    if (!question.minRange || !question.maxRange) {
                        return false;
                    } else if (question.minRange >= question.maxRange) {
                        return false;
                    } else {
                        return true;
                    };


                } else if (question.HasOptions) {


                    if (question.questionOptions.length === 0) {
                        return false;
                    } else {
                        return true;
                    }

                } else {
                    return true;
                };

            }; //isQuestionValidForSave



            $scope.deleteQuestion = function(question, index) {

                var confirm = window.confirm('Are you sure you want to delete this question?');

                if (confirm) {

                    // if the ident is 0, we haven't committed to DB yet, so just remove from array
                    if (question.Ident > 0) {

                        var delQuestion = RESTService.delete(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREQUIREMENT]), question.Ident);

                        delQuestion.then(function(pl) {

                                // return the new Ident and add to the object so any future edits are puts instead of post
                                $scope.init(0, false);

                                growl.success('This question has been successfully deleted.');

                            },
                            function(errorPl) {
                                growl.error($global.GetRandomErrorMessage());
                            });

                    } else {

                        $scope.EntityProjectQuestions.splice(index, 1);

                        // need to reset this otherwise, we get in a hung state with the active row logic
                        $scope.activeQuestionIndex = 0;

                        growl.success('This question has been successfully deleted.');


                    };

                }

            };

            $scope.toggleTextSort = function(question) {

                if (!question.showTextSort) {

                    question.showTextSort = true;

                } else {

                    question.showTextSort = false;

                };


            }; //toggleTextSort


            $scope.resortQuestionAlpha = function(question, reverse) {

                var array = $filter('orderBy')(question.questionOptions, 'toString()', reverse);

                question.questionOptions = array;

            };


            $scope.setAssignee = function($item, question) {
                question.ToDoAssigneeEntityIdent = $item.Ident;
                question.ToDoAssignee = $item.FullName;
                question.ToDoAssigneeProfilePhoto = $item.ProfilePhoto;
                question.ShowEditAssignee = false;
            }


            //Ensure that there is a debounce on the typeing filter
            var timeoutPromise;
            var delayInMs = 1000;
            $scope.getEntities = function(val) {
                $scope.loadingEntities = true;
                $timeout.cancel(timeoutPromise); //does nothing, if timeout alrdy done
                timeoutPromise = $timeout(function() { //Set timeout
                    return $scope.getEntitiesNow(val);
                }, delayInMs);
                return timeoutPromise;
            };


            $scope.getEntitiesNow = function(val) {

                var searchCriteria = [{
                    name: "keyword",
                    value: val
                }];

                var searchEntityForAssignGet;
                searchEntityForAssignGet = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.SEARCHENTITYFORASSIGN]), searchCriteria);

                return searchEntityForAssignGet.then(function(pl) {

                        return $filter('filter')(
                            pl.data.Entity.map(function(item) {

                                if (item.NPI) {

                                    item.DisplayName = item.FullName + ' (' + item.NPI + ')';

                                } else {

                                    item.DisplayName = item.FullName;

                                };

                                $scope.loadingEntities = false;
                                return item;
                            }),
                            function(item) {
                                if (item.Ident !== $scope.Profile.Entity[0].Ident) {
                                    return true;
                                }
                                return false;
                            });

                    },
                    function(errorPl) {

                    }
                );

            }; //getEntitiesNow


            $scope.showPreviewModal = function(Ident) {

                //(Setup) the modal and keep it in scope so we can call functions on it.
                $rootScope.PreviewModal = $modal.open({
                    animation: true,
                    templateUrl: 'PreviewModal.html',
                    scope: $rootScope,
                    size: 'lg'
                });

            };


            $scope.PlaceholderNA = function(type) {
                if (type == 'Number') {
                    return false;
                } else if (type == 'Number - Money') {
                    return false;
                } else if (type == 'Text - Email') {
                    return false;
                } else if (type == 'Text - Paragraph') {
                    return false;
                } else if (type == 'Text - Single Line') {
                    return false;
                } else if (type == 'Text - Website') {
                    return false;
                } else {
                    return true;
                }
            }


            // KEYBOARD BINDINGS //

            // CTRL (keyup) 
            Mousetrap.bind('mod', function() {
                SaveSortOrder();
            }, 'keyup');

            // CTRL + UP
            Mousetrap.bind('mod+up', function(event) {
                event.preventDefault();
                $scope.SortUp($scope.activeQuestionIndex, true);
            });

            // CTRL + DOWN
            Mousetrap.bind('mod+down', function(event) {
                event.preventDefault();
                $scope.SortDown($scope.activeQuestionIndex, true);
            });

            // CTRL + SHIFT + UP
            Mousetrap.bind('mod+shift+up', function(event) {
                event.preventDefault();
                $scope.SortTop($scope.activeQuestionIndex, true);
            });

            // CTRL + SHIFT + DOWN
            Mousetrap.bind('mod+shift+down', function(event) {
                event.preventDefault();
                $scope.SortBottom($scope.activeQuestionIndex, true);
            });

            // DELETE
            Mousetrap.bind('del', function(event) {
                event.preventDefault();
                $scope.deleteQuestion($scope.EntityProjectQuestions[$scope.activeQuestionIndex], $scope.activeQuestionIndex);
            });

            // ARROW UP
            Mousetrap.bind('up', function(event) {
                event.preventDefault();

                if ($scope.activeQuestionIndex > 0) {
                    var newIndex = $scope.activeQuestionIndex - 1;
                    // Load new question
                    $scope.activateQuestionRow($scope.EntityProjectQuestions[newIndex], newIndex, false);
                    // Set focus to question row
                    $window.document.getElementById('question' + newIndex).focus();
                    // Scroll if needed
                    ScrollOnSort(newIndex, 'up');
                }
            });

            // ARROW DOWN
            Mousetrap.bind('down', function(event) {
                event.preventDefault();

                if ($scope.activeQuestionIndex < $scope.EntityProjectQuestions.length) {
                    var newIndex = $scope.activeQuestionIndex + 1;
                    // Load new question
                    $scope.activateQuestionRow($scope.EntityProjectQuestions[newIndex], newIndex, false);
                    // Set focus to question row
                    $window.document.getElementById('question' + newIndex).focus();
                    // Scroll if needed
                    ScrollOnSort(newIndex, 'down');
                }
            });

            // SORTING FUNCTIONS //

            var sorted = false;

            // Sort question up
            $scope.SortUp = function(index, keyboard) {

                if (index > 0) {
                    var oldIndex = index;
                    var newIndex = index - 1;

                    // Update array
                    FinishSort(oldIndex, newIndex, 'up', keyboard);
                }

            }

            // Sort question down
            $scope.SortDown = function(index, keyboard) {

                if (index < $scope.EntityProjectQuestions.length - 1) {
                    var oldIndex = index;
                    var newIndex = index + 1;

                    // Update array
                    FinishSort(oldIndex, newIndex, 'down', keyboard);
                }

            }

            // Sort question to top
            $scope.SortTop = function(index, keyboard) {

                if (index > 0) {
                    var oldIndex = index;
                    var newIndex = 0;

                    // Update array
                    FinishSort(oldIndex, newIndex, 'top', keyboard);
                }

            }

            // Sort question to bottom
            $scope.SortBottom = function(index, keyboard) {

                if (index < $scope.EntityProjectQuestions.length - 1) {
                    var oldIndex = index;
                    var newIndex = $scope.EntityProjectQuestions.length - 1;

                    // Update array
                    FinishSort(oldIndex, newIndex, 'bottom', keyboard);
                }

            }

            var FinishSort = function(oldIndex, newIndex, direction, keyboard) {

                // Move the question obj in the array
                $scope.EntityProjectQuestions.splice(newIndex, 0, $scope.EntityProjectQuestions.splice(oldIndex, 1)[0]);

                // Update sortOrder property in array
                angular.forEach($scope.EntityProjectQuestions, function(value, key) {
                    $scope.EntityProjectQuestions[key].sortOrder = (key + 1);
                });

                // Set 'active' class on question row
                $scope.activeQuestionIndex = newIndex;

                // Push updates to DOM and give row focus
                // Note: $scope.$apply generates an error when called on button press
                // but $timeout isn't workin on key press so please accept this hacky 
                // solution until a better one is presented
                if (keyboard) {
                    $scope.$apply();
                    $window.document.getElementById('question' + newIndex).focus();
                } else {
                    $timeout(function() {
                        $window.document.getElementById('question' + newIndex).focus();
                    });
                }

                // Done sorting
                sorted = true;

                // Scroll panel if necessary
                ScrollOnSort(newIndex, direction);

            }

            // Scroll panel
            var ScrollOnSort = function(newIndex, direction) {

                // Question
                var questionElm = $window.document.getElementById('question' + newIndex);
                var questionHeight = questionElm.offsetHeight;
                var questionPos = questionElm.offsetTop - panelHeading;

                // Desktop
                // Need to scroll #SuperList
                if (windowWidth >= 992) {

                    // If the question is positioned lower than the viewable area, scroll a little bit
                    if (direction == 'up') {
                        // Looks like browser will handle this automatically,
                        // probably because the row has focus
                    } else if (direction == 'down') {
                        // Use bottom of row
                        questionPos = questionElm.offsetTop + questionHeight - panelHeading;

                        if (questionPos > formBuilderHeight) {
                            panelElm.scrollTop = panelElm.scrollTop + questionHeight;
                        }
                    } else if (direction == 'top') {
                        if (questionPos > panelElm.scrollTop) {
                            panelElm.scrollTop = 0;
                        }
                    } else if (direction == 'bottom') {
                        if (panelElm.scrollHeight > formBuilderHeight) {
                            panelElm.scrollTop = panelElm.scrollHeight;
                        }
                    }

                }
                // Mobile
                // Need to scroll window
                else {

                    // If the question is positioned lower than the viewable area, scroll a little bit
                    if (direction == 'up') {
                        // Looks like browser will handle this automatically,
                        // probably because the row has focus
                    } else if (direction == 'down') {
                        // Use bottom of row
                        questionPos = questionElm.getBoundingClientRect().top + questionHeight;

                        if (questionPos > windowHeight - 100) {
                            window.scrollTo(0, window.scrollY + questionHeight);
                        }
                    } else if (direction == 'top') {
                        window.scrollTo(0, 0);
                    } else if (direction == 'bottom') {
                        window.scrollTo(0, document.body.scrollHeight);
                    }

                }
            }

            // Save new sort order
            var SaveSortOrder = function() {

                // Only save if the array has been sorted
                if (sorted) {

                    // Update DB
                    var putAllQuestion = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREQUIREMENT]), $scope.EntityProjectQuestions);

                    putAllQuestion.then(function(pl) {
                            // We're good 
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                }
            }


            //default first item as selected
            $scope.init(0, true);

        }
    ]);
