'use strict'

angular
    .module('App.ForgotPasswordController', [])
    .controller('ForgotPasswordController', ['$scope',
    '$log',
    '$global',
    'RESTService',
	'growl',
function ($scope, $log, $global, RESTService, growl) {

            $log.debug("Controller: " + "ForgotPasswordController");

            $scope.forgotPasswordEmail = null;

            $scope.forgotPassword = function () {

                if ($scope.forgotPasswordEmail) {

                    var forgotPassPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.FORGOTPASS]), {
                        email: $scope.forgotPasswordEmail
                    });

                    forgotPassPost.then(function (pl) {
                            growl.success('An email has been sent to ' + $scope.forgotPasswordEmail + ' with a link to reset your password.');
                            $scope.forgotPasswordEmail = null;
                        },
                        function (errorPl) {

                            growl.error('We are unable to send an email to the provided address at this time. Please contact support at help@ahealthtech.com.');
                            $scope.forgotPasswordEmail = null;
                        });
                } else {
                    growl.error('Please provide an email address.');
                }

            };

}]);