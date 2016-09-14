'use strict'

angular.module('App.Services')
    .service('registrationService', ['growl', 'identity', 'RESTService', '$global', '$state', function(growl, identity, RESTService, $global, $state) {

        this.checkRegistrationID = function(id) {

            if (id){

                var searchCriteria = [{
                    name: "guid",
                    value: id
                }];

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.REGISTER]);

                var registerGet = RESTService.getWithParams(URI, searchCriteria);

                return registerGet.then(function(pl) {

                        // success, no need to do anything

                     }, 
                     function (errorPl) {

                        $state.go('registernotvalid');

                });

            } else  {

                $state.go('registernotvalid');

            };

        }; // checkRegistrationID

        this.register = function(username, password, confirmPassword) {

            if (confirmPassword == password) {

                var registerPOST;
                var postData = {
                    Username: username,
                    Password: password
                }
                registerPOST = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.REGISTER]), postData);

                registerPOST.then(function (pl) {
                    identity.login(username, password).then(
                        //success
                        function (value) {

                            if (value.success) {
                                // do nothing, login will redirect to appropriate page
                            } else {
                                growl.error(value.msg);
                            }

                        }
                    );
                },
                    function (errorPl) {

                        if (errorPl.status == 400) { //bad request
                            growl.error('Registration could not be completed at this time.');
                        } else if (errorPl.status == 401) {
                            growl.error('Unfortunately your account is not in the correct status to complete registration. Please contact support.');
                        } else if (errorPl.status == 403) {
                            growl.error('This username already exists in the system. Please try again.');
                        } else { //server failover
                           growl.error('Registration could not be completed at this time.');
                        }

                    }
                );

            } else {
                growl.error('Your password does not match the confirm password.');
            }; //if (confirmPassword == password)

        }; //register

        this.sendRegistrationEmail = function(entityIdent, entityEmailIdent) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.REGISTER]);
            URI = URI + '/' + entityIdent + '/sendemail';

            // if we include the specific email ident, only send it to that email address, not all for the given entity
            if (entityEmailIdent){

                URI = URI + '/' + entityEmailIdent;

            };

            var registerPut = RESTService.put(URI);

            return registerPut;

        }; //sendRegistrationEmail

  }]);