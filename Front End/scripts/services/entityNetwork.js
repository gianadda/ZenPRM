'use strict'

angular.module('App.Services')
    .service('entityNetworkService', ['RESTService', '$global', function(RESTService, $global) {

        this.getEntityNetwork = function() {

            var searchCriteria = [{
                name: "includePersons",
                value: true
            },{
                name: "includeOrganizations",
                value: true
            }];

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYNETWORK]);
            var entityNetworkGET = RESTService.getWithParams(URI, searchCriteria);

            return entityNetworkGET.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return [];

                });

        }; // getEntityNetwork

        this.getEntityNetworkPersonResources = function() {

            var searchCriteria = [{
                name: "includePersons",
                value: true
            },{
                name: "includeOrganizations",
                value: false
            }];

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYNETWORK]);
            var entityNetworkGET = RESTService.getWithParams(URI, searchCriteria);

            return entityNetworkGET.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return [];

                });

        }; // getEntityNetworkPersonResources

        this.getEntityNetworkNonPersonResoures = function() {

            var searchCriteria = [{
                name: "includePersons",
                value: false
            },{
                name: "includeOrganizations",
                value: true
            }];

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYNETWORK]);
            var entityNetworkGET = RESTService.getWithParams(URI, searchCriteria);

            return entityNetworkGET.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return [];

                });

        }; // getEntityNetworkNonPersonResoures

  }]);