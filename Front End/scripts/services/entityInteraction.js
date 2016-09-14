'use strict'

angular.module('App.Services')
    .service('entityInteractionService', ['RESTService', '$global', function(RESTService, $global) {

        this.AddEntityInteraction = function(toEntityIdent, interactionText) {

            var putData = {
                ToEntityIdent: toEntityIdent,
                InteractionText: interactionText,
                InteractionTypeIdents: '',
                Important: false,
                Active: true
            };

            var AddEntityInteractionPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYINTERACTION]), putData);

            return AddEntityInteractionPost.then(function(pl) {
                    return pl;
                },
                function(errorPl) {
                    return errorPl;
                });
        }; // AddEntityInteraction

        this.DeleteEntityInteraction = function(entityInteractionIdent) {

            var deleteEntityInteractionDelete;
            var postData = {
                EntityInteractionIdent: entityInteractionIdent
            };

            deleteEntityInteractionDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYINTERACTION]), postData);

            return deleteEntityInteractionDelete.then(function(pl) {
                    return pl;
                },
                function(errorPl) {
                    return errorPl;

                }
            );

        }; // DeleteEntityInteraction


        this.EditEntityInteraction = function(entityInteractionIdent, interactionText) {

            var putData = {
                InteractionText: interactionText
            };

            var EditEntityInteractionPut = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYINTERACTION]), entityInteractionIdent, putData);

            return EditEntityInteractionPut.then(function(pl) {
                    return pl;
                },
                function(errorPl) {
                    return errorPl;
                });
        }; // EditEntityInteraction

        this.LoadInteractions = function(entityIdent) {

            var getInteractions = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYINTERACTION]), entityIdent);

            return getInteractions.then(function(pl) {
                    return pl.data;
                },
                function(errorPl) {
                    return errorPl;
                });
        }; // LoadInteractions

    }]);
