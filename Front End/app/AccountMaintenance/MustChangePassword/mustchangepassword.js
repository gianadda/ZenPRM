'use strict'

angular
    .module('App.MustChangePasswordController', [])
    .controller('MustChangePasswordController', ['$scope',
    '$state',
    '$stateParams',
    'identity',
	'growl',
function ($scope, $state, $stateParams, identity, growl) {

    $scope.init = function(){

        $scope.newPassword = '';
        $scope.confirmNewPassword = '';

        // validate the guid
        identity.validateMustChangePassword($stateParams.guid);

    }; //init

    //delegates to identity.changePassword()
    $scope.changePassword = function () {

        var promise = identity.mustChangePass($scope.newPassword, $scope.confirmNewPassword);

        promise.then(function (result) {

                $state.go('site.home');

            },
            function (errorResult) {
                growl.error(errorResult.msg);
            });
    }; //changePassword

    $scope.init();

}]);