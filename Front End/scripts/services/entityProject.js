'use strict'

angular.module('App.Services')
    .service('entityProjectService', ['RESTService', '$filter', '$global', function(RESTService, $filter, $global) {

        this.getEntityProject = function(EntityProjectIdent) {

            var getEntityProject = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]), EntityProjectIdent);

            return getEntityProject;

        };
        
        this.getRequirementTypes = function() {

            var getRequirementType = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.REQUIREMENTTYPE]));

            return getRequirementType.then(function(pl) {

                return pl.data;

            });

        }; //getRequirementTypes


        this.getRequirementTypesForImport = function() {

            var getRequirementType = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.REQUIREMENTTYPE]));

            var RequirementTypes = [];

            return getRequirementType.then(function(pl) {

                RequirementTypes = $filter('filter')(pl.data, function(e) {
                    var valid = false;
                    if (e.RequiresAnswer == true) {
                        /*
                        1   Number
                        2   Text
                        3   Date/Time
                        4   Options/List
                        5   Bit
                        */

                        if (e.EntitySearchDataTypeIdent == 1 || e.EntitySearchDataTypeIdent == 2 || e.EntitySearchDataTypeIdent == 3 || e.EntitySearchDataTypeIdent == 4 || e.EntitySearchDataTypeIdent == 5) {
                            valid = true;
                        }
                    }
                    return valid;
                }, true);

                return RequirementTypes;

            });

        }; //getRequirementTypesForImport

        this.ReactivateProject = function(Ident) {

                var postReactivateEntityProject;
                var postData = {
                    EntityProjectIdent: Ident
                }

                postReactivateEntityProject = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREACTIVATE]), postData);

                return postReactivateEntityProject;

        };  //ReactivateProject
  
        this.sendProjectEmail = function(projectIdent, customMessage) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]);
            URI = URI + '/' + projectIdent + '/sendemail';

            var postData = {
                customMessage: customMessage
            };

            var entityProjectPOST = RESTService.post(URI, postData);

            return entityProjectPOST;

        }; //sendProjectEmail

  }]);