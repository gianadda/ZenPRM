'use strict'

//Based on: http://stackoverflow.com/questions/22537311/angular-ui-router-login-authentication
//Plunker: http://plnkr.co/edit/UkHDqFD8P7tTEqSaCOcc?p=preview

angular
    .module('App.UserManagement', [])
    // identity is a service that tracks the user's identity. 
    // calling identity() returns a promise while it does what you need it to do
    // to look up the signed-in user's identity info. for example, it could make an 
    // HTTP request to a rest endpoint which returns the user's name, roles, etc.
    // after validating an auth token in a cookie. it will only do this identity lookup
    // once, when the application first runs. you can force re-request it by calling identity(true)
    .factory('identity', [
        '$q',
        '$log',
        '$state',
        'RESTService',
        '$global',
        'growl',
        '$sessionStorage',
        function($q, $log, $state, RESTService, $global, growl, $sessionStorage) {

            var _baseIdentity = undefined,
                _identity = undefined,
                _authenticated = false,
                _mustChangePassword = false,
                _delegationMode = false;

            return {

                //Returns a boolean that tells you if the user's identity is loaded
                isIdentityResolved: function() {
                    //$log.debug("identity.isIdentityResolved()", angular.isDefined(_identity));

                    //if null or undefined, will return false
                    if (_identity) {
                        return true;
                    } else {
                        return false;
                    }
                },

                //Returns a boolean that tells you if the user is authenticated
                isAuthenticated: function() {
                    //$log.debug("identity.isAuthenticated() ", _authenticated);
                    return _authenticated;
                },

                mustChangePassword: function() {
                    return _mustChangePassword;
                },

                delegationMode: function() {
                    return _delegationMode;
                },

                isBaseIdentitySystemAdmin: function() {

                    if (_baseIdentity) {
                        return _baseIdentity.roles[0] == $global.sysRoleEnum.ZENTEAM;

                    } else {
                        return false;
                    }

                },

                //Expects a role
                //Returns a boolean that is true if the current user has the role that is passed in
                isInRole: function(role) {
                    $log.debug("identity.isInRole()", role);
                    if (!_authenticated || !_identity.roles) return false;
                    $log.debug("_identity.roles :", _identity.roles);
                    return _identity.roles.indexOf(role) != -1;
                },

                //Iterates over a users role and repeatedly calls "isInRole" to see if the user has any of the roles provided
                //Expects a list of roles that are authorized to view the page
                //Returns a boolean true if the current users roles match any of the provided roles, false if not.
                isInAnyRole: function(roles) {
                    $log.debug("identity.isInAnyRoles() ", roles);

                    if (!_authenticated || !_identity.roles) return false;

                    for (var i = 0; i < roles.length; i++) {
                        if (this.isInRole(roles[i])) return true;
                    }

                    return false;
                },



                //Expects: an identity object (user)
                //Returns: VOID (Sets the _authenticated to true if the users identity has been resolved)
                authenticate: function(identity) {
                    $log.debug("identity.authentitcate()");
                    _identity = identity;
                    _authenticated = identity != null;
                },

                getUserIdent: function() {
                    if (_identity && _identity.ident) {
                        return _identity.ident;
                    }
                },

                //used in header.js for displaying logged in user name
                getUserName: function() {
                    if (_identity && _identity.name && _identity.name.length > 0) {
                        return _identity.name;
                    }
                },

                //grab the user's roles if they're available, might be useful for displaying
                getRoles: function() {
                    if (_identity && _identity.roles && !isNaN(_identity.roles)) {
                        return _identity.roles;
                    }
                },

                //Expects: Boolean force : should we force a new identity lookup
                //Returns: A promise that is resolved once the user is logged in
                identity: function(force) {
                    var deferred = $q.defer();

                    $log.debug("identity.identity()", _identity);

                    if (force === true) _identity = undefined;

                    // check and see if we have retrieved the identity data from the server. if we have, reuse it by immediately resolving
                    if (_identity) {
                        $log.debug("Loading stored _identity", _identity);
                        deferred.resolve(_identity);

                        return deferred.promise;
                    }


                    var loginGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.LOGIN]));

                    loginGet.then(function(pl) {

                        //is the user logged in?
                        if (!Boolean(pl.data[0])) {
                            $log.debug("User is not logged in");

                            _identity = null;
                            _baseIdentity = null;
                            _authenticated = false;

                            if (Boolean(pl.data[1])) {
                                _mustChangePassword = true;
                            }

                            deferred.resolve();

                        } else { //user is logged in, so lets set and return their data

                            $log.debug("User is logged in", pl);

                            _authenticated = true;
                            _identity = {
                                ident: Number(pl.data[4]),
                                name: String(pl.data[3]),
                                roles: [Number(pl.data[2])]
                            };
                            _baseIdentity = angular.copy(_identity);
                            _delegationMode = pl.data[5];

                            //TODO: Test this functionality
                            if (Boolean(pl.data[1])) { //user must change password
                                //go to the change password screen
                                //dunno if this is safe
                                //the user can hit any url after this point from changePassword 
                                //because they are logged in after pressing url from emeail
                                $log.debug("User has to change password");
                                _mustChangePassword = true;
                                $state.go('mustChangePassword');
                            } else {
                                $log.debug("User does not have to change password");
                                _mustChangePassword = false;
                            }

                        }

                        deferred.resolve(_identity);

                    }, function(err) {

                        $log.debug("loginGet Fail: ", err);

                        //The request failed, lets deauth them just in case.

                        deferred.resolve(_identity);
                    });


                    return deferred.promise;
                },

                //Expects: String username, password
                //Returns: HTML alerts for failure or success notification
                login: function(username, password, projectGUID) {

                    $log.debug("Called identity.login()");
                    $sessionStorage.$reset();
                    var alert = '';

                    var params = {
                        username: username,
                        password: password,
                        projectGUID: projectGUID
                    }

                    var pathToLogin = RESTService.getControllerPath([$global.RESTControllerNames.LOGIN]);

                    var loginPost = RESTService.post(pathToLogin, params);

                    return loginPost.then(function(pl) {
                            if (pl.data) {

                                $log.debug("Post to Login Endpoint Successful: ", pl);

                                var mustChangePassword = Boolean(pl.data[2]);
                                _delegationMode = Boolean(pl.data[6]);

                                if (mustChangePassword) {
                                    //$log.debug("User Must Change Password");
                                    _mustChangePassword = true;
                                    $state.go('mustChangePassword');
                                } else { //successful login

                                    _identity = {
                                        ident: Number(pl.data[5]),
                                        name: String(pl.data[1]),
                                        roles: [Number(pl.data[0])] //Role Ident
                                    };
                                    _baseIdentity = angular.copy(_identity);
                                    _authenticated = true;
                                    _mustChangePassword = false;

                                    var hasDelegates = Boolean(pl.data[7]);
                                    var projectIdent = parseInt(pl.data[9]);


                                    if (hasDelegates && projectIdent == 0) {

                                        // else, if we have multiple delegates, then take you to the delegate menu
                                        $state.go('site.delegatesMenu');

                                        return {
                                            success: true,
                                            msg: ''
                                        };

                                    } else {

                                        var hasProjects = Boolean(pl.data[8]);

                                        // first, if they are in delegation mode, just take them to the customer dashboard
                                        // if they have projects, take them there, and if they only have 1, take them directly to the project
                                        if (!_delegationMode && hasProjects){

                                            if (projectIdent > 0){

                                                $state.go('site.Project', {ident: projectIdent, entityIdent: Number(pl.data[5])});

                                            } else {

                                                $state.go('site.EntityProjects', {ident: Number(pl.data[5])});
                                            
                                            };


                                        } else {

                                            // otherwise, they will already be delegated into the customer dashboard,
                                            // or, returned to the normal profile page
                                            $state.go('site.home');

                                        };


                                        return {
                                            success: true,
                                            msg: ''
                                        };
                                    };

                                }
                            } else {
                                if (username !== '' || password !== '') {
                                    growl.error("Invalid Username or Password");
                                }

                            }

                        },
                        function(errorPl) {

                            $log.log("Login Unsuccessful");

                            if (errorPl.status == 401) { //bad username/pass
                                growl.error("Invalid Username or Password");
                            } else if (errorPl.status == 403) { //Session locked, tried five random usernames within 5 minutes
                                growl.error('Your session is locked and you cannot attempt to login for 5 minutes.');
                            } else { //server failover
                                growl.error('Login request failed. Please contact support at help@ahealthtech.com.');
                            }

                        });


                },
                loginAsDelegate: function(delegateIdent) {

                    $log.debug("Called identity.loginAsDelegate()");

                    var pathToLogin = RESTService.getControllerPath([$global.RESTControllerNames.LOGINDELEGATE]);

                    if (delegateIdent) {
                        var loginDelegate = RESTService.get(pathToLogin, delegateIdent);
                    } else {
                        var loginDelegate = RESTService.delete(pathToLogin);
                    };

                    return loginDelegate.then(function(pl) {
                            if (pl.data) {

                                $log.debug("Post to Login As Delegate Endpoint Successful: ", pl);

                                var mustChangePassword = Boolean(pl.data[2]);
                                _delegationMode = Boolean(pl.data[6]);


                                _identity = {
                                    ident: Number(pl.data[5]),
                                    name: String(pl.data[1]),
                                    roles: [Number(pl.data[0])] //Role Ident
                                };
                                _authenticated = true;
                                _mustChangePassword = false;

                                return true;

                            } else {

                                return false;
                            }

                        },
                        function(errorPl) {

                            $log.log("Login As Delegate Unsuccessful");

                            return false;

                        });

                },
                //Expects: String username, password
                //Returns: HTML alerts for failure or success notification
                loginExternal: function(projectGUID) {

                    $log.debug("Called identity.loginExternal()");
                    $sessionStorage.$reset();
                    var alert = '';

                    var params = [{
                        name: "guid",
                        value: projectGUID
                    }];

                    var pathToLogin = RESTService.getControllerPath([$global.RESTControllerNames.LOGINEXTERNAL]);

                    var loginGET = RESTService.getWithParams(pathToLogin, params);

                    return loginGET.then(function(pl) {
                            if (pl.data) {

                                $log.debug("Post to Login External Endpoint Successful: ", pl);

                                _delegationMode = Boolean(pl.data[6]);

                                _identity = {
                                        ident: Number(pl.data[5]),
                                        name: String(pl.data[1]),
                                        roles: [Number(pl.data[0])] //Role Ident
                                    };
                                    _baseIdentity = angular.copy(_identity);
                                    _authenticated = true;
                                    _mustChangePassword = false;

                                    var hasDelegates = Boolean(pl.data[7]);
                                    var projectIdent = parseInt(pl.data[9]);

                                    if (hasDelegates && projectIdent == 0) {

                                        // else, if we have multiple delegates, then take you to the delegate menu
                                        $state.go('site.delegatesMenu');

                                        return {
                                            success: true,
                                            msg: ''
                                        };

                                    } else {

                                        var hasProjects = Boolean(pl.data[8]);

                                        // if they have projects, take them there, and if they only have 1, take them directly to the project
                                        if (hasProjects){

                                            if (projectIdent > 0){

                                                $state.go('site.Project', {ident: projectIdent, entityIdent: Number(pl.data[5])});

                                            } else {

                                                $state.go('site.EntityProjects', {ident: Number(pl.data[5])});
                                            
                                            };


                                        } else {

                                            // otherwise, they will already be delegated into the customer dashboard,
                                            // or, returned to the normal profile page
                                            $state.go('site.home');

                                        };

                                        return {
                                            success: true,
                                            msg: ''
                                        };
                                    };
                            } 

                        },
                        function(errorPl) {

                            $log.log("Login Unsuccessful");

                            if (errorPl.status == 401) { //bad username/pass
                                growl.error('Your attempt to sign in with your social account was not successful.');
                                //$state.go('login');
                            } else if (errorPl.status == 403) { 
                                var source = String(errorPl.data[0]);
                                growl.error('This email address already has a login associated with it for ZenPRM. The source of this login is: ' + source + '. Please utilize this service for sign in. If the source is ZenPRM, and you do not know your account password, you can utilize the Forgot Password functionality.', {ttl: 20000});
                                //$state.go('login');
                            } else { //server failover

                                if (errorPl.data && errorPl.data.length > 0){

                                    var source = String(errorPl.data[0]);
                                    var message = 'Your log in attempt has failed because your ' + source + ' profile does not contain a verified email address. You can complete the verification of your email address on your ' + source + ' profile and retry, or login within another service.';

                                    growl.error(message, {ttl: 20000});

                                } else {

                                    growl.error('Your login request has failed or your account is not already registered. In order to log in to ZenPRM, you most already have been invited to complete registration. Please contact support at help@ahealthtech.com.', {ttl: 20000});

                                };

                                //$state.go('login');
                            }

                            // if the user has the project GUID, then return them to that page instead of the login page
                            if (projectGUID){
                                $state.go('project-registration', {id: projectGUID});
                                
                            } else {
                                $state.go('login');
                            };

                        });


                },

                //Deprecated
                setRoles: function(sysRoleIdent) {

                    $log.debug("Called identity.setRoles()");

                    var sysRoleEnum = {
                        SYSTEM_ADMIN: 1
                    };

                    switch (sysRoleIdent) {
                        case sysRoleEnum.SYSTEM_ADMIN:
                            $log.debug("User is Admin");
                            return ['User', 'Admin'];
                        default:
                            $log.debug("User is User");
                            return ['User'];
                    }

                },

                //Logs out current user
                //Return: void
                logout: function() {

                    var deferred = $q.defer();

                    $log.debug("identity.logout()");

                    RESTService.delete(RESTService.getControllerPath([$global.RESTControllerNames.LOGIN]))
                        .then(
                            function() {
                                $log.debug("Logout Successful");

                                //log out
                                _identity = null;
                                _baseIdentity = null;
                                _authenticated = false;
                                _mustChangePassword = false;

                                deferred.resolve();
                            },
                            function() {
                                $log.debug("Logout Failed");
                                deferred.reject();
                            }
                        );

                    return deferred.promise;

                },

                //Expects: currentPassword, newPassword, confirmedNewPassword
                //Returns: HTML alerts/confirmation formated for boostrap explaining error
                changePassword: function(currentPassword, newPassword, confirmNewPassword) {
                    var deferred = $q.defer();
                    $log.debug("identity.changePassword()");

                    $log.debug("Loaded Controller: " + "ChangePasswordController");

                    if (newPassword && newPassword === confirmNewPassword) {

                        var changePassPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.CHANGEPASS]), {
                            currentPassword: currentPassword,
                            newPassword: newPassword
                        });

                        changePassPost.then(function(pl) {
                                if (pl.data) {
                                    //let each controller leveraging identity.changePassword decide what to do
                                    deferred.resolve({
                                        msg: 'Your password has been changed.'
                                    });
                                } else {
                                    deferred.reject({
                                        msg: 'Please be sure your new password does not match your old. If the issue continues please contact support at help@ahealthtech.com.'
                                    });
                                }
                            },
                            function(errorPl) {
                                deferred.reject({
                                    msg: 'Your current password is not correct.'
                                });
                            }
                        );
                    } else if (!angular.isDefined(newPassword)) {
                        deferred.reject({
                            msg: 'Please make sure your password matches the labeled criteria.'
                        });
                    } else if (newPassword && newPassword !== confirmNewPassword) {
                        deferred.reject({
                            msg: 'Your new password does not match the confirm password.'
                        });
                    }

                    return deferred.promise;

                }, //end changePassword

                //Expects: guid
                //Returns: validates if the must change password URL is still valid
                validateMustChangePassword: function(guid) {

                    if (guid) {

                        var searchCriteria = [{
                            name: "guid",
                            value: guid
                        }];

                        var URI = RESTService.getControllerPath([$global.RESTControllerNames.CHANGEPASS]);

                        var mustChangePassGet = RESTService.getWithParams(URI, searchCriteria);

                        return mustChangePassGet.then(function(pl) {

                                // success, no need to do anything other than set must change password = true
                                _mustChangePassword = true;

                            },
                            function(errorPl) {

                                $state.go('forgotPasswordNotValid');

                            });

                    } else {

                        // if we dont have a GUID, see if we already have must change password set (i.e. password expired)
                        // if not, then lets dump the user out to bad password link
                        if (!_mustChangePassword) {

                            $state.go('registernotvalid');

                        };

                    };

                }, //end changePassword


                //Expects: newPassword, confirmedNewPassword
                //Returns: HTML alerts/confirmation formated for boostrap explaining error
                mustChangePass: function(newPassword, confirmNewPassword) {
                        var deferred = $q.defer();
                        $log.debug("identity.mustChangePassword()");

                        $log.debug("Loaded Controller: " + "MustChangePasswordController");

                        if (newPassword && newPassword === confirmNewPassword) {

                            var changePassPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.MUSTCHANGEPASS]), {
                                password: newPassword
                            });

                            changePassPost.then(function(pl) {
                                    if (pl.data) {
                                        //let each controller leveraging identity.changePassword decide what to do
                                        deferred.resolve({
                                            msg: 'Your password has been changed.'
                                        });
                                    } else {
                                        deferred.reject({
                                            msg: 'Please be sure your new password does not match your old password. If the issue continues please contact support at help@ahealthtech.com.'
                                        });
                                    }
                                },
                                function(errorPl) {
                                    deferred.reject({
                                        msg: 'Your password could not be changed at this time. If the issue continues please contact support at help@ahealthtech.com.'
                                    });
                                }
                            );
                        } else if (!angular.isDefined(newPassword)) {
                            deferred.reject({
                                msg: 'Please make sure your password matches the labeled criteria.'
                            });
                        } else if (newPassword && newPassword !== confirmNewPassword) {
                            deferred.reject({
                                msg: 'Your new password does not match the confirm password.'
                            });
                        }

                        return deferred.promise;

                    } //end changePassword

            }; //close identity object
        }
    ])

// authorization service's purpose is to wrap up authorize functionality
// it basically just checks to see if the principal is authenticated and checks the root state 
// to see if there is a state that needs to be authorized. if so, it does a role check.
// this is used by the state resolver to make sure when you refresh, hard navigate, or drop onto a
// route, the app resolves your identity before it does an authorize check. after that,
// authorize is called from $stateChangeStart to make sure the principal is allowed to change to
// the desired state
.factory('authorization', ['$rootScope', '$state', 'identity', '$log',
    function($rootScope, $state, identity, $log) {
        return {
            authorize: function() {
                return identity.identity()
                    .then(function() {
                        var isAuthenticated = identity.isAuthenticated();

                        var mustChangePassword = identity.mustChangePassword();

                        $log.debug("authorization.authorize");

                        if ($rootScope.toState.data) {
                            $log.debug("Authorize data.roles ", $rootScope.toState.data.roles);
                        } else {
                            $log.debug("$rootScope.toState.data doesn't exist");
                        }

                        if ($rootScope.toState.data && $rootScope.toState.data.roles && $rootScope.toState.data.roles.length > 0 && !identity.isInAnyRole($rootScope.toState.data.roles)) {
                            if (isAuthenticated) {
                                $log.debug("User is authenticated but does not have permission to view the state: ", $state.current);
                                $state.go('accessdenied'); // user is signed in but not authorized for desired state
                            } else {
                                $log.debug("User is not authenticated, sending them to login");
                                // user is not authenticated. stow the state they wanted before you
                                // send them to the signin state, so you can return them when you're done
                                $rootScope.returnToState = $rootScope.toState;
                                $rootScope.returnToStateParams = $rootScope.toStateParams;

                                // now, send them to the signin state so they can log in
                                $state.go('login');
                            }
                        }
                    });
            }
        };
    }
])
