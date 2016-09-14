'use strict'

angular.module('App.Services')
    .service('zenOpenDataService', ['RESTService', '$global', function(RESTService, $global) {

        this.getEntityByNPI = function(NPI) {

            var getEntityByNPI = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ZENOPENDATA, $global.RESTControllerNames.NPPESLOOKUP]), NPI);

            return getEntityByNPI;

        };

        this.getReferralDataByNPI = function(NPI) {

            var searchCriteria = [{
                name: "NPI",
                value: NPI
            }];

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ZENOPENDATA, $global.RESTControllerNames.REFERRALS]);

            var referralsGet = RESTService.getWithParams(URI, searchCriteria);

            return referralsGet.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return {};

                });

        }; // getReferralDataByNPI

  }]);