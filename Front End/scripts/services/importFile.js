'use strict'

angular.module('App.Services')
    .service('importFileService', ['$global','$q','RESTService', function($global,$q,RESTService) {

        this.getImportColumns = function() {

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.IMPORTCOLUMNS]);

                var getColumns = RESTService.get(URI);

                return getColumns.then(function(pl) {

                        if (pl.data && pl.data.length > 0){
                            return pl.data;
                        } else {
                            return [];
                        };

                    },
                    function(errorPl) {
                      return $q.reject(errorPl);
                    }
                );

        }; // getImportColumns

        this.importResources = function(resources) {

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYIMPORT]);

                var postResources = RESTService.post(URI, resources);

                return postResources.then(function(pl) {

                        if (pl.data && pl.data.length > 0){
                            return pl.data;
                        } else {
                            return [];
                        };

                    },
                    function(errorPl) {
                      return $q.reject(errorPl);
                    }
                );

        }; // importResources

        this.importResourcesVerifyEntity = function(resources) {

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYIMPORTVERIFY]);

                var postResources = RESTService.post(URI, resources);

                return postResources.then(function(pl) {

                        if (pl.data && pl.data.length > 0){
                            return pl.data;
                        } else {
                            return [];
                        };

                    },
                    function(errorPl) {
                      return $q.reject(errorPl);
                    }
                );

        }; // importResourcesVerifyEntity

  }]);