'use strict'

angular.module('App.Services')
    .service('zenWatsonService', ['RESTService', '$global', function(RESTService, $global) {

        this.postTone = function(Text) {

            var searchCriteria = {
                text: Text
            };

            var postTone = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.WATSONTONEANALYZER]), searchCriteria);
            
            return postTone.then(function(pl) {
                var returnData = pl.data;
                return returnData;
            },
            function(errorPl) {
                return errorPl.data;
            });

        };


        this.postToneByQuestionIdent = function(Ident) {

            var searchCriteria = {
                ident: parseInt(Ident)
            };

            var postToneByQuestionIdent = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.WATSONTONEANALYZERBYIDENT]), searchCriteria);
            
            return postToneByQuestionIdent.then(function(pl) {
                var returnData = pl.data;
                return returnData;
            },
            function(errorPl) {
                return errorPl.data;
            });

        };

  }]);