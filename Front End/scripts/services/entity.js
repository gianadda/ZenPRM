'use strict'

angular.module('App.Services')
    .service('entityService', ['RESTService', '$global', '$q', function(RESTService, $global, $q) {

        this.addEntityEmail = function(entityIdent, email) {

                var postEntityEmailPost;
                var postData = {
                    EntityIdent: entityIdent,
                    Email: email,
                    Notify: false,
                    Verified: false,
                    VerifiedASUserIdent: 0,
                    Active: true
                };

                postEntityEmailPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYEMAIL]), postData);

                return postEntityEmailPost.then(function(pl) {

                    var returnData = pl.data;
                    returnData.email = postData;
                    returnData.email.Ident = pl.data.Ident;

                    return returnData;
                    },
                    function(errorPl) {
                      return errorPl.data;
                    }
                );

        }; // add Entity Email

        this.addEntityToNetworkByNPI = function(NPI) {

        	var postData = {
        		NPI: NPI,
                Active: true
        	};

            var entityAddToNetworkPUT = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ADDENTITYTONETWORKBYNPI]), postData);

            return entityAddToNetworkPUT;

        };


        this.changeEntityType = function(entityIdent, entityTypeIdent, NPI) {

            var postData = {
                NPI: NPI,
                EntityTypeIdent: entityTypeIdent
            };

            var postEntityType = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY, entityIdent, $global.RESTControllerNames.CHANGE]), postData);

            return postEntityType.then(function(pl) {

                return pl.data;
                
                },
                function(errorPl) {
                  return $q.reject(errorPl);
                }
            );

        }; //changeEntityType

  }]);