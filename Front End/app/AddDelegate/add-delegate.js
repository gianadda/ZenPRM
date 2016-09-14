angular.module('App.AddDelegateDirective', [])
.directive('addDelegate', function() {

  return {
    restrict: 'E',
    templateUrl: 'AddDelegate/add-delegate.html',
    controller: function (delegationService, $global, growl, $rootScope, $scope) {

    	$scope.addDelegate = function(){

    		delegationService.addDelegate($scope.Delegate).then(function (pl) {

             if (pl.data && pl.data.addedEntity){

                var message = 'We\'ve added ' + pl.data.entityName + ' to the system and sent them an email at ' + pl.data.email + ' to complete the registration process. Once they do so, they will be able to access your account and complete work on your behalf.';

                if ($scope.atRegistration){

                  message = message + ' At this time you may continue on to register your own account.';

                };

                growl.success(message);

             } else {

                var message = 'Great! We\'ve found ' + pl.data.entityName + ' in the system and their account is setup to log in Next time they do so, they will be able to access your account and complete work on your behalf. We\'ve also sent them an email to let them know this process occurred.';

                if ($scope.atRegistration){

                  message = message + ' At this time you may continue on to register your own account.';

                };

                growl.success(message);

             };

             $scope.Delegate = {};

        },
        function(errorPl) {

            if(errorPl && errorPl.status === 403) {

                var message = 'This person already has access to your account in ZenPRM, so we\'re not going to add it in again.';

                growl.warning(message);

            } else {

              growl.error($global.GetRandomErrorMessage());

            };

        });
                  
    	};

    }

  };

});