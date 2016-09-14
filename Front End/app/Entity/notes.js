angular
    .module('App.NotesController', ['ngTagsInput', 'toggle-switch', 'xeditable'])
    .controller('NotesController', [
    '$scope',
    '$rootScope',
    '$filter',
    '$global',
    'RESTService',
    'growl',
    'MyProfileService',
    '$stateParams',
    'identity',
    '$state',
    'entityInteractionService',
function ($scope, $rootScope, $filter, $global, RESTService, growl, MyProfileService, $stateParams, identity, $state, entityInteractionService) {

            $scope.newInteractionText = '';
            $scope.EditMode = false;
            $scope.NotesLoaded = false;

            $scope.EntityIdent = $stateParams.ident;
            $scope.EntityLoaded = false;

            if ($scope.EntityIdent) {

                MyProfileService.getProfile($scope.EntityIdent).then(function (pl) {
                        $scope.EntityDetails = pl.Entity[0];
                        $scope.EntityLoaded = true;

                        $rootScope.PageTitle = $scope.EntityDetails.FullName + ' - Notes';
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.EntityLoaded = true;
                    });

            }
            else {
                $state.go('site.notfound');
            }

            $scope.LoadInteractions = function () {

                entityInteractionService.LoadInteractions($scope.EntityIdent).then(function (data) {
                        $scope.Interactions = data;
                        $scope.NotesLoaded = true;
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.NotesLoaded = true;
                    });

            };

            $scope.Loaded = function() {
                if ($scope.EntityLoaded && $scope.NotesLoaded) {
                    return true;
                }
            }

            $scope.removeEntityInteraction = function (entityInteractionIdent) {

                entityInteractionService.DeleteEntityInteraction(entityInteractionIdent).then(function (data) {
                        $scope.LoadInteractions();
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            };


            $scope.AddEntityInteraction = function () {

                entityInteractionService.AddEntityInteraction($stateParams.ident, $scope.newInteractionText).then(function (pl) {
                    growl.success($global.GetRandomSuccessMessage());
                    $scope.newInteractionText = '';
                    $scope.newInteractionTags = [];
                    $scope.InteractionForm.$setPristine();
                    $scope.LoadInteractions();
                },
                function (errorPl) {
                    growl.error($global.GetRandomErrorMessage());
                });

            }; // AddEntityInteraction

            $scope.loadTagsByIdent = function (ident) {

                return $filter('orderBy')($filter('filter')($scope.Interactions.InteractionTags,
                    function (item) {
                        return item.EntityInteractionIdent === ident;
                    }
                ), "Name1");

            };

            $scope.criteriaMatch = function (criteria) {
                return function (item) {
                    return item.EntityInteractionIdent === criteria.Ident;
                };
            };

            $scope.getMomentDate = function (date) {
                return moment(date).fromNow();

            }

            $scope.loadTags = function (query, datasource) {

                return $filter('orderBy')($filter('filter')(datasource, query), "Name1");

            };

            $scope.CreateToDo = function (interaction) {

                var WorkingToDoDate = moment().format("MM/DD/YYYY");
                var ToDoDate = moment().format("MM/DD/YYYY");
                var confirmText = "";

                //added this in to parse out any dates, if we find one we'll use it as the "toDo" date
                try {
                    var knwlInstance = new Knwl('english');
                    knwlInstance.init(interaction.InteractionText);
                    var dates = knwlInstance.get('dates');
                    if (dates.length > 0) {
                        if (dates[0].month !== "unknown" && dates[0].day !== "unknown" && dates[0].year !== "unknown") {
                            WorkingToDoDate = dates[0].month + '/' + dates[0].day + '/' + dates[0].year;
                            confirmText = "We noticed that you mentioned a date in this interaction, would you like us to set " + WorkingToDoDate + " as the due date? \n \n \nPressing 'Cancel' will still create the To-Do with today as the due date.";
                        } else if (dates[0].month !== "unknown" && dates[0].day !== "unknown") {
                            WorkingToDoDate = dates[0].month + '/' + dates[0].day + '/' + moment().format("YY");
                            confirmText = "We noticed that you mentioned a date in this interaction, would you like us to set " + WorkingToDoDate + " as the due date? \n \n \nPressing 'Cancel' will still create the To-Do with today as the due date.";
                        }

                    }
                    //console.log(ToDoDate);
                } catch (err) {}

                if (confirmText) {
                    var r = confirm(confirmText);
                    if (r == true) {
                        ToDoDate = WorkingToDoDate;
                    } else {
                        ToDoDate = moment().format("MM/DD/YYYY");;
                    }
                }
                var putData = {
                    EntityIdent: identity.getUserIdent(),
                    ToDoTypeIdent: 3, //Interaction
                    DueDate: ToDoDate,
                    Title: 'Interaction on ' + interaction.AddDateTime,
                    Desc1: interaction.InteractionText,
                    LinkText: 'Interaction',
                    LinkURL: '#/interaction/' + $scope.EntityDetails.Ident.toString(),
                    Link2Text: $scope.EntityDetails.FullName,
                    Link2URL: '#/profile/' + $scope.EntityDetails.Ident.toString(),
                    Link3Text: '',
                    Link3URL: '',
                    AssigneeEntityIdent: identity.getUserIdent(),
                    Active: true
                }
                var addPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTODO]), putData);

                addPost.then(function (pl) {
                        growl.success($global.GetRandomSuccessMessage());
                        if (pl.data.length > 0) {

                            $state.go('site.TodoList', {
                                ToDoIdent: pl.data[0].Ident
                            });
                        }

                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }

            // Edit an exiting note
            $scope.EditNote = function (ident) {

                // Loop through note and set current to edit mode (show text box)
                angular.forEach($scope.Interactions.EntityInteraction, function(value, key) {
                    if (value.Ident == ident) {
                        if (value.EditMode) {
                            value.EditMode = false;
                        }
                        else {
                            value.EditMode = true;
                        }
                    }
                });

            };

            // Save an edited note
            $scope.SaveExistingNote = function (ident, text) {

                entityInteractionService.EditEntityInteraction(ident, text).then(function (pl) {
                    // Hide text box
                    angular.forEach($scope.Interactions.EntityInteraction, function(value, key) {
                        if (value.Ident == ident) {
                            value.EditMode = false;
                        }
                    });

                    // Reload to show edit stamp
                    $scope.LoadInteractions();

                    growl.success($global.GetRandomSuccessMessage());
                },
                function (errorPl) {
                    growl.error($global.GetRandomErrorMessage());
                });
            }

            // HELPER FUNCTIONS //

            $scope.IsCustomer = function() {
                return $global.isCustomer();
            }

            $scope.IsMyProfile = function(ident) {
                var bolValid = false;
                if (identity.getUserIdent() == ident) {
                    bolValid = true;
                }
                return bolValid;
            }

            $scope.LoadInteractions();

}]);