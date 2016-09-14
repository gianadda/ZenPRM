angular
    .module('App.TicketsController', [])
    .controller('TicketsController', [
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
        '$q',
        '$stateParams',
        '$anchorScroll',
        '$location',
        'exportFileService',
        '$templateCache',
        function($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, growl, $window, identity, LookupTablesService, MyProfileService, $q, $stateParams, $anchorScroll, $location, exportFileService, $templateCache) {

            $templateCache.put('ngTagsInput/auto-complete.html',
                "<div class=\"autocomplete\" ng-if=\"suggestionList.visible\"><ul class=\"suggestion-list\"><li class=\"suggestion-item\" ng-repeat=\"item in suggestionList.items track by track(item)\" ng-class=\"{selected: item == suggestionList.selected}\"  ng-mouseenter=\"suggestionList.select($index)\"><ti-autocomplete-match data=\"::item\" ng-click=\"addSuggestionByIndex($index)\"></ti-autocomplete-match> <i class=\"fa fa-times right\" ng-click=\"item.RemoveMe=true;addSuggestionByIndex($index)\" ng-confirm-click=\"Are you sure you want to delete this category? It will no longer be available to anyone using the system.\"></i></li></ul></div>"
            );

            window.onresize = setHeight;
            $scope.CurrentlySelectedToDoIdent = 0;
            $scope.JustAddedToDoIdent = 0;
            $scope.loading = true;
            $scope.firstLoad = true;
            $scope.ToDoLoading = false;
            $scope.ShowNoTicketsMessage = false;
            $scope.ShowTab = 'Details';

            $scope.LookupTables = LookupTablesService;
            $scope.loadingEntities = false;
            $scope.NumberToShow = 50;
            $scope.NumberToAddToShown = 50;


            //    $scope.ShowCompleted = true; //start it as "show Completed" and let the toggle function turn it off and set the text

            $scope.toggleShowCompleted = function() {
                if (!$scope.ShowCompleted) {
                    $scope.ShowCompleted = true;
                    $scope.showCompletedText = 'hide completed';
                } else {
                    $scope.ShowCompleted = false;
                    $scope.showCompletedText = 'show completed';
                }
            }
            $scope.toggleShowCompleted();

            $scope.filterByShowCompleted = function(ToDo) {
                var show = false;
                if ($scope.ShowCompleted) {
                    show = true;
                } else if (ToDo.Completed) {
                    show = false;
                } else {
                    show = true;
                }
                return show;
            };

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

            };


            $scope.setRegarding = function($item, ToDo) {
                ToDo.RegardingEntityIdent = $item.Ident;
                ToDo.Regarding = $item.FullName;
                ToDo.RegardingProfilePhoto = $item.ProfilePhoto
                ToDo.ShowEditRegarding = false;
            }
            $scope.setAssignee = function($item, ToDo) {
                ToDo.AssigneeEntityIdent = $item.Ident;
                ToDo.Assignee = $item.FullName;
                ToDo.AssigneeProfilePhoto = $item.ProfilePhoto
                ToDo.ShowEditAssignee = false;
            }

            $scope.CurrentGroupData = {
                CurrentGrouping: 'DueDate',
                GroupByOptions: [{
                    Name: 'Due Date',
                    Value: 'DueDate'
                }, {
                    Name: 'Assignee',
                    Value: 'Assignee'
                }],
                getCurrentGroup: function() {
                    return $scope.CurrentGrouping;
                }
            }


            function setHeight() {

                if ($scope.Profile.EntityToDo.length > 0) {

                    var windowHeight = window.innerHeight;
                    var windowWidth = window.innerWidth;

                    if (windowWidth >= 992) {
                        var headerHeight = 65;
                        var panelHeading = 62;
                        var contentPadding = 50;
                        var formBuilderHeight = windowHeight - headerHeight - contentPadding - panelHeading;

                        document.getElementById('SuperList').style.height = formBuilderHeight + 'px';
                    }
                }

            }

            $scope.GetTags = function(ToDo) {

                return $filter('filter')(ToDo.Tags, { Active: true }, true);
            }

            $scope.ValidateAndAddCategory = function(tag, ToDo) {
                var valid = false;

                if (tag.RemoveMe == true) {
                    //Remove the tag!
                    valid = false;

                    var postData = { Ident: tag.Ident }

                    var deletePost = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTODO]) + '/DeleteCategory', postData);

                    deletePost.then(function(pl) {
                            $timeout($scope.EditToDo(ToDo, false, true, false), 400);
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });

                } else {

                    valid = true;
                }
                return valid;
            }

            $scope.getTickets = function() {

                $scope.loading = true;
                var getToDo;

                if ($scope.ShowCompleted == true) {
                    getToDo = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTODO]) + '/' + $scope.ShowCompleted + '/' + $scope.omniSearchDateRange);
                } else {
                    getToDo = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTODO]) + '/' + $scope.ShowCompleted + '/-1');
                }

                getToDo.then(function(pl) {

                        $scope.Profile.EntityToDo = pl.data.EntityToDo;
                        $scope.Profile.EntityToDoEntityToDoCategoryXRef = pl.data.EntityToDoCategory;
                        $scope.Profile.EntityToDoComment = pl.data.EntityToDoComment;

                        //This will determine how many ToDos should show in the navigation and update the RootScope variable.
                        var arr = $filter('filter')($scope.Profile.EntityToDo,
                            function(todo) {

                                var overdue = new Date(todo.DueDate) < new Date();
                                var notDueOnMinDate = todo.DueDate !== '01/01/1900';
                                var notComplete = !todo.Completed;
                                var active = todo.Active;
                                return overdue && notDueOnMinDate && notComplete && active;
                            }
                        );
                        $rootScope.ToDoCount = arr.length;

                        angular.forEach($scope.Profile.EntityToDo, function(key, val) {

                            $scope.Profile.EntityToDo[val].DueDate = $scope.getCleanedDate($scope.Profile.EntityToDo[val].DueDate);

                            angular.forEach($scope.Profile.EntityToDoEntityToDoCategoryXRef, function(item, index) {
                                if (item.EntityToDoIdent == $scope.Profile.EntityToDo[val].Ident) {

                                    //Now find the Category and put it in the Tags array
                                    var cat = $filter('filter')($scope.Profile.EntityToDoCategory, { Ident: item.EntityToDoCategoryIdent }, true)
                                    if (cat.length > 0) {
                                        if (!$scope.Profile.EntityToDo[val].Tags) {
                                            $scope.Profile.EntityToDo[val].Tags = [];
                                        }
                                        $scope.Profile.EntityToDo[val].Tags.push(cat[0]);
                                    }

                                }
                            })

                            $scope.Profile.EntityToDo[val].Comments = $filter('filter')($scope.Profile.EntityToDoComment, { EntityToDoIdent: $scope.Profile.EntityToDo[val].Ident }, true)


                            if ($scope.CurrentGroupData.CurrentGrouping == 'DueDate') {


                                if ($scope.Profile.EntityToDo[val].DueDate !== '') {
                                    $scope.Profile.EntityToDo[val].groupColumn = new Date($scope.Profile.EntityToDo[val].DueDate);

                                    if ($scope.isOverdue($scope.Profile.EntityToDo[val])) {

                                        //for some reason moment is off by a day?
                                        $scope.Profile.EntityToDo[val].groupText = moment($scope.Profile.EntityToDo[val].DueDate).add(1, 'days').fromNow();

                                    } else {

                                        //for some reason moment is off by a day?
                                        $scope.Profile.EntityToDo[val].groupText = 'Due ' + moment($scope.Profile.EntityToDo[val].DueDate).add(1, 'days').fromNow();

                                    }
                                } else {
                                    $scope.Profile.EntityToDo[val].groupColumn = new Date();
                                    //for some reason moment is off by a day?
                                    $scope.Profile.EntityToDo[val].groupText = 'No Due Date set';

                                }

                            } else {
                                $scope.Profile.EntityToDo[val].groupColumn = $scope.Profile.EntityToDo[val].Assignee;
                                $scope.Profile.EntityToDo[val].groupText = $scope.Profile.EntityToDo[val].Assignee;
                            }

                        })

                        $scope.Profile.EntityToDo = $filter('orderBy')($scope.Profile.EntityToDo, 'groupColumn');

                        if (($stateParams.ToDoIdent && $scope.firstLoad) || $scope.JustAddedToDoIdent) {

                            $scope.firstLoad = false;
                            if ($scope.JustAddedToDoIdent) {
                                $scope.CurrentlySelectedToDoIdent = $scope.JustAddedToDoIdent;
                                $scope.JustAddedToDoIdent = 0;
                            } else {
                                $scope.CurrentlySelectedToDoIdent = parseInt($stateParams.ToDoIdent);
                            }
                            $location.hash($scope.CurrentlySelectedToDoIdent.toString());
                            $anchorScroll();
                        }

                        if ($scope.CurrentlySelectedToDoIdent == 0) {
                            // Draw list full width
                            $scope.SuperListClass = "full";
                        }

                        if ($scope.Profile.EntityToDo.length == 0) {
                            $scope.ShowNoTicketsMessage = true;
                        } else {
                            $scope.ShowNoTicketsMessage = false;
                        }

                        $scope.loading = false;

                        setHeight();
                    },

                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }



            $scope.init = function() {
                MyProfileService.getMyProfile().then(function(pl) {
                        $scope.Profile = pl;
                        $scope.getTickets();


                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    });
            }
            $scope.getMomentDate = function(date) {
                return moment(date).fromNow();

            }


            $scope.getCleanedDate = function(date) {


                if (date == '') {
                    return '';
                } else if (moment(date).format('MM/DD/YYYY') !== '01/01/1900') {
                    return moment(date).format('MM/DD/YYYY');
                } else {
                    return '';
                }

            }

            $scope.isCompleteTicket = function(todo) {
                return todo.ToDoStatusIdent === 3; //Closed

            }

            $scope.isCurrentTicket = function(ident) {
                return $scope.CurrentlySelectedToDoIdent == ident;

            }

            $scope.isOverdue = function(todo) {
                return new Date(todo.DueDate) < new Date();

            }
            $scope.selectToDo = function(todo, currentItemForm) {

                $scope.ToDoLoading = true;

                //This means I'm changing todos and not empty
                if ($scope.CurrentlySelectedToDoIdent !== 0 && $scope.CurrentlySelectedToDoIdent !== todo.Ident) {

                    $timeout($scope.EditToDo(todo, false, false, false)).then(function() {
                        $scope.CurrentlySelectedToDoIdent = todo.Ident;

                        $timeout(function() {
                            $scope.ToDoLoading = false;
                        }, 200);
                    })

                } else {

                    if (todo) {
                        $scope.CurrentlySelectedToDoIdent = todo.Ident;
                    }

                    $timeout(function() {
                        $scope.ToDoLoading = false;
                    }, 200);
                }

                $scope.SuperListClass = '';


            }

            $scope.PadTicketNumber = function(ticketNumber) {
                var str = "" + ticketNumber
                var pad = "000000"
                return pad.substring(0, pad.length - str.length) + str

            }


            $scope.AddComment = function(todo) {

                var putData = {
                    EntityToDoIdent: todo.Ident,
                    CommentText: todo.NewComment,
                    Active: true
                }
                var addPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTODO]) + '/AddComment', putData);

                addPost.then(function(pl) {
                        //growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

                // Set the current tab to Comments so that it doesn't change when saved.
                $scope.ShowTab = 'Comments';
            }


            $scope.RemoveComment = function(ident, todo) {
                var postData = { Ident: ident }

                var deletePost = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTODO]) + '/DeleteComment', postData);

                deletePost.then(function(pl) {
                        $scope.EditToDo(todo, false, true, true);
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }


            $scope.AddToDo = function() {

                var putData = {
                    ToDoInitiatorTypeIdent: 1, //Inbound
                    ToDoTypeIdent: 1, //Phone Call
                    ToDoStatusIdent: 1, //Open
                    RegardingEntityIdent: $scope.Profile.Entity[0].Ident, //Not set
                    AssigneeEntityIdent: $scope.Profile.Entity[0].Ident, //Not set
                    Title: '',
                    Desc1: '',
                    Active: true
                }
                var addPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTODO]), putData);

                addPost.then(function(pl) {
                        $scope.JustAddedToDoIdent = pl.data[0].Ident;
                        $scope.init();
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }

            $scope.EditToDo = function(todo, markAsComplete, reloadResults, displaySaveSuccess) {

                // Set the current tab to Details by default
                $scope.ShowTab = 'Details';

                if (todo.NewComment) {
                    $scope.AddComment(todo);
                }

                todo.CategoryIdentCSV = '';
                todo.NewCategoryCSV = '';
                angular.forEach(todo.Tags, function(item, index) {
                    if (todo.CategoryIdentCSV == '') {
                        if (item.Ident) {
                            todo.CategoryIdentCSV = item.Ident;
                        }
                    } else {
                        if (item.Ident) {
                            todo.CategoryIdentCSV = todo.CategoryIdentCSV + ', ' + item.Ident;
                        }
                    }

                    if (todo.NewCategoryCSV == '') {
                        if (!item.Ident && item.text) {
                            todo.NewCategoryCSV = item.text;
                        }
                    } else {
                        if (!item.Ident && item.text) {
                            todo.NewCategoryCSV = todo.NewCategoryCSV + ', ' + item.text;
                        }
                    }
                })

                var editPut = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTODO]), todo);

                editPut.then(function(pl) {

                        if (displaySaveSuccess){

                            growl.success($global.GetRandomSuccessMessage());

                        };


                        if (reloadResults) {
                            $scope.init();
                        }
                        if (markAsComplete) {
                            $scope.CompleteToDo(todo);
                        }

                        if (todo.NewCategoryCSV !== '') {
                            MyProfileService.getMyProfile().then(function(pl) {
                                    $scope.Profile.EntityToDoCategory = pl.EntityToDoCategory;
                                },
                                function(errorPl) {
                                    growl.error($global.GetRandomErrorMessage());

                                });
                        }

                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });


            }

            $scope.RemoveToDo = function(todo) {

                var deletePost = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTODO]), todo);

                deletePost.then(function(pl) {
                        $scope.init();
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }


            $scope.omniSearchFilter = function(row) {

                var match = (row.Ident == $scope.omniSearch) ||
                    $filter('lowercase')(row.ToDoStatus).indexOf($filter('lowercase')($scope.omniSearch)) !== -1 ||
                    $filter('lowercase')(row.ToDoType).indexOf($filter('lowercase')($scope.omniSearch)) !== -1 ||
                    $filter('lowercase')(row.Regarding).indexOf($filter('lowercase')($scope.omniSearch)) !== -1 ||
                    $filter('lowercase')(row.Assignee).indexOf($filter('lowercase')($scope.omniSearch)) !== -1 ||
                    $filter('lowercase')(row.Title).indexOf($filter('lowercase')($scope.omniSearch)) !== -1 ||
                    $filter('lowercase')(row.Desc1).indexOf($filter('lowercase')($scope.omniSearch)) !== -1 ||
                    $filter('lowercase')(row.StartDate).indexOf($filter('lowercase')($scope.omniSearch)) !== -1 ||
                    $filter('lowercase')(row.DueDate).indexOf($filter('lowercase')($scope.omniSearch)) !== -1 ||
                    $scope.omniSearch == '';

                if (!match) {

                    angular.forEach(row.Tags, function(item) {

                        if ($filter('lowercase')(item.Name1).indexOf($filter('lowercase')($scope.omniSearch)) !== -1) {
                            match = true;
                        }
                    })
                }

                if (!match) {
                    angular.forEach(row.Comments, function(item) {

                        if ($filter('lowercase')(item.CommentText).indexOf($filter('lowercase')($scope.omniSearch)) !== -1 ||
                            $filter('lowercase')(item.Commenter).indexOf($filter('lowercase')($scope.omniSearch)) !== -1) {
                            match = true;
                        }
                    })
                }

                /*          if ($scope.ShowCompleted && $scope.omniSearchDateRange !== "-1") {


                              var today = moment();

                              var a = moment(row.StartDate);
                              var b = moment(row.DueDate);
                              var c = moment(row.AddDateTime);
                              var d = moment(row.EditDateTime);

                              if (a.diff(today, 'days') > (Number($scope.omniSearchDateRange) * -1) ||
                                  b.diff(today, 'days') > (Number($scope.omniSearchDateRange) * -1) ||
                                  c.diff(today, 'days') > (Number($scope.omniSearchDateRange) * -1) ||
                                  d.diff(today, 'days') > (Number($scope.omniSearchDateRange) * -1)) {
                                  //
                              } else {
                                  match = false;
                              }

                          }*/

                return match;
            };

            $scope.ExportToCSV = function() {

                //var tickets = $filter('filter')($scope.Profile.EntityToDo, filterText);
                var tickets = [];

                angular.forEach($scope.Profile.EntityToDo, function(value, key) {

                    if ($scope.omniSearchFilter(value)) {

                        tickets.push(value);

                    };

                });

                exportFileService.exportTicketsToCSV(tickets, $scope.Profile.EntityToDoCategory);

            };

            $scope.init();

        }
    ]);
