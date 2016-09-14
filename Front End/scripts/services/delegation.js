'use strict'

angular.module('App.Services')
    .service('delegationService', ['RESTService', '$global', function(RESTService, $global) {

        this.addDelegate = function(delegate) {

            var delegatesPut = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYDELEGATE]), delegate);

            return delegatesPut;

        };

        this.claimResource = function(entityIdent) {

        	var URL = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYDELEGATE]);

        	URL = URL + '/' + entityIdent;

            var delegatesPut = RESTService.post(URL);

            return delegatesPut;

        };


        this.getDelegateUsers = function() {

            var delegatesGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYDELEGATE]));

            return delegatesGet;

        };

  }]);