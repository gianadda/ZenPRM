'use strict'

angular.module('App.Services')
    .service('geocodingService', ['$http', function($http) {

        this.getLocationGeoCodes = function(location) {

            var geocodes = {
                latitude: 0.0,
                longitude: 0.0
            }

            var getgoogleMapsAPI = {
                method: 'GET',
                url: encodeURI('https://maps.googleapis.com/maps/api/geocode/json?address=' + location)
            };
            return $http(getgoogleMapsAPI).then(function(pl) {

                    if (pl.data && pl.data.results.length > 0 && pl.data.results[0].geometry) {

                        geocodes.latitude = pl.data.results[0].geometry.location.lat;
                        geocodes.longitude = pl.data.results[0].geometry.location.lng;

                    };

                    return geocodes;

                },
                function(errorPl) {

                    return geocodes;

                });
        };

    }]);
