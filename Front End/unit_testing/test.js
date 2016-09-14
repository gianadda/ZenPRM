 angular
     .module('myApp', [])
     .directive('dumbExample', function () {
         return {
             replace: true,
             restrict: 'AE',
             scope: {
                 person: '='
             },
             template: '<span>Hey, {{person}}!</span>'
         };
     });

angular
   .module('myApps', [])
   .factory('Login', function ($http) {
     var data = {
       response: null,
       error: null
     };
     data.login = function (username, password) {
       $http.post('/login', {username: username, password: password}).success(function (response) {
          data.response = response;
       }).error(function (error) {
          data.error = error;
       }); 
     };
     return data;
 });