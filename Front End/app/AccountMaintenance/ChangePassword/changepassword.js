'use strict'

angular
    .module('App.ChangePasswordController', [])
    .controller('ChangePasswordController', ['$scope',
    '$log',
    '$q',
    '$state',
    'identity',
	'growl',
    '$global',
function ($scope, $log, $q, $state, identity, growl, $global) {


            $scope.newPassword = '';
            $scope.confirmNewPassword = '';
            $scope.currentPassword = '';

            //delegates to identity.changePassword()
            $scope.changePassword = function () {

                var promise = identity.changePassword($scope.currentPassword, $scope.newPassword, $scope.confirmNewPassword);

                promise.then(function (result) {
                        growl.success('Your password has been successfully changed!');
                        $state.go('site.home');
                    },
                    function (errorResult) {
                        growl.error(errorResult.msg);
                    });

            }



}]);