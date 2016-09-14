'use strict'

angular
    .module('App.NavigationController', [])
    .controller('NavigationController', [
        '$scope',
        '$rootScope',
        '$log',
        '$global',
        '$state',
        'identity',
        'growl',
        'RESTService',
        'MyProfileService',
        '$filter',
        '$pendolytics',
        '$sessionStorage',
        'delegationService',
        function($scope, $rootScope, $log, $global, $state, identity, growl, RESTService, MyProfileService, $filter, $pendolytics, $sessionStorage, delegationService) {

            $rootScope.loadingDelegates = true;
            $rootScope.isExternalLogin = false;

            $scope.init = function() {
                // Console reporting
                $log.debug("Loading NavigationController");

                // Establish user identity
                $scope.GetUserIdentity();

                // Draw appropriate navigation links
                $scope.DrawNavMenu();

                // Get profile image and to-do count
                $scope.GetProfileData($scope.userIdent);

                // Draw delegate links in settings menu
                $scope.getDelegateUsers();
            };

            // Get user data
            $scope.GetUserIdentity = function() {
                $scope.userIdent = identity.getUserIdent();
                $scope.userName = identity.getUserName();
                $scope.userRoles = identity.getRoles();
            }

            // Determine what links to display in navigation menu
            $scope.DrawNavMenu = function() {
                $scope.userType = 'entity';
                if ($global.isCustomer()) {
                    $scope.userType = 'customer';
                }
            }

            // Set active state in navigation when on sub pages
            $rootScope.isInSection = function(str) {
                $scope.inSection = false;

                if ($state.current.url.substring(0, str.length) == str) {
                    $scope.inSection = true;
                }
                return $scope.inSection;
            }

            // Set delegate colors in 
            $rootScope.DelegateClass = function(ident) {
                if (ident) {
                    return "delegate" + ident.toString().slice(-1);
                }
                return "";
            }

            // Get profile image and to-do count for navigation
            $scope.GetProfileData = function(ident) {

                MyProfileService.getProfile(ident).then(
                    function(result) {
                        //src="assets/img/profile.png" 
                        $scope.userProfilePhoto = result.Entity[0].ProfilePhoto;
                        $rootScope.isExternalLogin = result.Entity[0].ExternalLogin;
                        $scope.EntityTypeIdent = result.Entity[0].EntityTypeIdent;

                        var arr = $filter('filter')(result.EntityToDo,
                            function(todo) {

                                var overdue = new Date(todo.DueDate) < new Date();
                                var notDueOnMinDate = todo.DueDate !== '01/01/1900';
                                var notComplete = !todo.Completed;
                                var active = todo.Active;
                                return overdue && notDueOnMinDate && notComplete && active;
                            }

                        );

                        $rootScope.ToDoCount = arr.length;

                    },
                    function(error) {
                        // handle errors here
                        $scope.userProfilePhoto = '';
                    }

                );
            }

            // Determine if we're in delegation mode
            $scope.isDelegationMode = function() {
                return identity.delegationMode();
            }

            // Get delegate accounts to populate settings menu
            $scope.getDelegateUsers = function() {

                delegationService.getDelegateUsers().then(function(pl) {
                        $rootScope.delegateUsers = pl.data;
                        $rootScope.loadingDelegates = false;
                    },
                    function(errorPl) {
                        $scope.delegateUsers = null;
                        $rootScope.loadingDelegates = false;
                    });

            };

            // Switch context into delegate account
            $rootScope.logInAs = function(delegate) {

                var delegateIdent = delegate.ToEntityIdent;


                // need to clear the current cached profile since were switching context
                // otherwise the previous delegates info could appear in the new account
                // not a security issue rather a context issue (noticed this on the bookmarked projects)
                MyProfileService.clearProfileCache();

                // if we're already in delegation mode, we need to logout as the old user and back in as the new user
                if ($scope.isDelegationMode()) {

                    identity.loginAsDelegate(null).then(
                        function(value) {


                            identity.loginAsDelegate(delegateIdent).then(
                                //success
                                function(value) {

                                    if (value) {

                                        $scope.init();
                                        $sessionStorage.$reset();

                                        //if we on the site.home, then reload, otherwise, redirect
                                        if ($global.isCustomer() && $state.current.name === 'site.dashboard') {
                                            $state.reload();
                                        } else if (!$global.isCustomer() && $state.current.name === 'site.MyProfile') {
                                            $state.reload();
                                        } else {
                                            $state.go('site.home');
                                        };

                                    } else {

                                        $state.go('login');
                                        growl.error('Unable to switch to context under delegation. Please contact support.');

                                    };

                                }
                            );

                        }

                    );

                } else { // were not already in as a delegate, so just login

                    identity.loginAsDelegate(delegateIdent).then(
                        //success
                        function(value) {

                            if (value) {

                                $scope.init();

                                //if we on the site.home, then reload, otherwise, redirect
                                if ($global.isCustomer() && $state.current.name === 'site.dashboard') {
                                    $state.reload();
                                } else if (!$global.isCustomer() && $state.current.name === 'site.MyProfile') {
                                    $state.reload();
                                } else {
                                    $state.go('site.home');
                                };

                            } else {

                                $state.go('login');
                                growl.error('Unable to switch to context under delegation. Please contact support.');

                            };
                        }

                    ); //identity.loginAsDelegate(delegateIdent).then

                }; //if ($scope.isDelegationMode())

            }; //$scope.logInAs

            // Return to my account (when in delegation mode)
            $scope.logOutAs = function() {

                identity.loginAsDelegate(null).then(
                    //success
                    function(value) {
                        if (value) {

                            $scope.init();

                            //if we on the site.home, then reload, otherwise, redirect
                            if ($global.isCustomer() && $state.current.name === 'site.dashboard') {
                                $state.reload();
                            } else if (!$global.isCustomer() && $state.current.name === 'site.MyProfile') {
                                $state.reload();
                            } else {
                                $state.go('site.home');
                            };

                        } else {

                            $state.go('login');
                            growl.error('Unable to switch to context under delegation. Please contact support.');

                        };
                    }
                );
            };

            // Log out of system
            $scope.logout = function() {
                var promise = identity.logout();

                promise.then(function() {
                    $state.go("login");
                });
            }

            // Open Help Menu
            $scope.HelpMenu = function() {
                $scope.menuActive = !$scope.menuActive;
                pendo.toggleLauncher();
            }

            //Initialize
            $scope.init();
        }
    ]);
