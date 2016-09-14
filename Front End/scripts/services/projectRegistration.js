'use strict'

angular.module('App.Services')
    .service('projectRegistrationService', ['RESTService', '$global', '$q', function(RESTService, $global, $q) {


        this.registerForOpenProject = function(guid, entity) {

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT, guid, $global.RESTControllerNames.REGISTER]);

                var postRegister = RESTService.post(URI, entity);

                return postRegister.then(function(pl) {

                      return true;
                    },
                    function(errorPl) {
                      return $q.reject(errorPl);
                    }
                );

        }; // registerForOpenProject

        this.verifyOpenProjectLink = function(guid) {

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT, guid, $global.RESTControllerNames.VERIFYOPENPROJECTLINK]);

                var getProject = RESTService.get(URI);

                return getProject.then(function(pl) {

                        if (pl.data && pl.data.length > 0){
                            return pl.data[0];
                        } else {
                            return {};
                        };

                    },
                    function(errorPl) {
                      return $q.reject(errorPl);
                    }
                );

        }; // verifyOpenProjectLink

  }]);