angular.module('App.zenCookieWarning', [])
.directive('zenCookieWarning', function() {
  return {
    restrict: 'E',
    scope: true,
    templateUrl: 'directives/zen-cookie-warning/zen-cookie-warning.html',
    controller: function ($global, $scope) {

        $scope.cookiesDisabled = !navigator.cookieEnabled;

        if (!$scope.cookiesDisabled){

        	// ok, so navigator said that cookies are enabled
        	// but much of the internet has said this wont tell you if 
        	// the browser (IE) is blocking cookies.. so lets test and verify
        	document.cookie = "ZenPRMCookieTest=Added";

        	var test = $global.getCookieByName("ZenPRMCookieTest");

        	// if the cookie is there
        	if (test == "Added"){

        		//clean it up, we dont want to actually store it
        		document.cookie = "ZenPRMCookieTest=Added; expires=Thu, 01 Jan 1970 00:00:00 UTC";

        	} else {

        		//otherwise, we've determined that cookies are blocked
        		$scope.cookiesDisabled = true;

        	};

        }; //if (!$scope.cookiesDisabled)




    }

  };

});