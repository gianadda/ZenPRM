'use strict'

angular
    .module('App.HeaderController', [])
    .controller('HeaderController', [
    '$scope',
    '$log',
    '$global',
    'identity',
    '$state',
    '$rootScope',
    'RESTService',
    'growl',
function ($scope, $log, $global, identity, $state, $rootScope, RESTService, growl) {

            $scope.logout = function () {
                var promise = identity.logout();

                promise.then(function () {
                        $state.go("login");
                    },
                    function () {
                        //$state.go("login");
                    });
            }

            $scope.toggleNav = function () {
                $rootScope.navToggled = !$rootScope.navToggled;
            };

            $scope.getDelegateUsers = function () {

                var delegatesGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYDELEGATE]));

                delegatesGet.then(function (pl) {
                        $scope.delegateUsers = pl.data;
                    },
                    function (errorPl) {
                        $scope.delegateUsers = null;
                    });

            };

            $scope.init = function () {

                $log.debug("Loading HeaderController");

                $scope.userName = identity.getUserName();
                $scope.userRoles = identity.getRoles();

                $rootScope.navToggled = false;

                $scope.getDelegateUsers();

            };

            //Initialize
            $scope.init();

            $scope.isDelegationMode = function () {
                return identity.delegationMode();
            }

            $scope.logInAs = function (delegateIdent) {

                identity.loginAsDelegate(delegateIdent).then(
                    //success
                    function (value) {
                        
                        if (value) {
                          
                            // 10/21: CJM: Note this isn't done. Our expectation is that this will move to a different controller, so were not going
                            // to spend the time to get this 100% until its moved over there.
                            // Also, this hasn't been tested with multiple delegate options
                            // successfully logged in as delegate
                            $state.reload();
                            
                        } else {
                            
                            $state.go('login');
                            growl.error('Unable to switch to context under delegation. Please contact support.');
                            
                        };
                        
                    }
                );

            };

            $scope.logOutAs = function () {

                identity.loginAsDelegate(null).then(
                    //success
                    function (value) {
                         if (value) {
                          
                            // 10/21: CJM: Note this isn't done. Our expectation is that this will move to a different controller, so were not going
                            // to spend the time to get this 100% until its moved over there.
                            // Also, this hasn't been tested with multiple delegate options
                             
                            // successfully return to orig user
                            $state.reload();
                            
                        } else {
                            
                            $state.go('login');
                            growl.error('Unable to switch to context under delegation. Please contact support.');
                            
                        };
                    }
                );
            };

}]);