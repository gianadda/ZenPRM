'use strict'

angular.module('App.Services')
    .service('entityHierarchyService', ['RESTService', '$global', function(RESTService, $global) {

        this.GetEntityHierarchy = function (entityIdent, reverseLookup) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYHIERARCHY]);

            if (reverseLookup){

                var searchParams = [{
                                name: "reverseLookup",
                                value: true
                        }];

                var entityHierarchyGET = RESTService.getWithParams(URI, searchParams, entityIdent);

            } else {

                var entityHierarchyGET = RESTService.get(URI, entityIdent);

            };

            return entityHierarchyGET.then(function(pl) {

                    if (reverseLookup){

                        return pl.data.Hierarchy;
                    
                    } else {

                        return pl.data;

                    }
                },
                function(errorPl) {

                    return [];

                });
            
        }; // GetEntityHierarchy

        this.getEntityHierarchyAsTags = function(entityIdent, reverseLookup) {

        	var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYHIERARCHY]);

            if (reverseLookup){

                var searchParams = [{
                                name: "reverseLookup",
                                value: true
                        }];

                var entityHierarchyGET = RESTService.getWithParams(URI, searchParams, entityIdent);

            } else {

                var entityHierarchyGET = RESTService.get(URI, entityIdent);

            };

            return entityHierarchyGET.then(function(pl) {

                    if (reverseLookup){

                        var hierarchyTags = [];

                        if (pl.data && pl.data.Hierarchy){

                                // we need to breakup our object so that it is per type in our tags repeater
                                // this will ensure each object that is rendered is bound separately
                                angular.forEach(pl.data.Hierarchy, function(value, key) {

                                    if (hierarchyTags[value.HierarchyTypeIdent]){

                                        hierarchyTags[value.HierarchyTypeIdent].tags.push(value);

                                    } else {

                                        hierarchyTags[value.HierarchyTypeIdent] = {};
                                        hierarchyTags[value.HierarchyTypeIdent].tags = [];

                                        hierarchyTags[value.HierarchyTypeIdent].tags.push(value);

                                    }; // if ($scope.hierarchyTags[value.HierarchyTypeIdent])

                                }); //angular.forEach(data.Hierarchy

                            }; //if (data && data.Hierarchy)

                        return hierarchyTags;

                    } else {

                        return pl.data;

                    };

                },
                function(errorPl) {

                    return [];

                });

        }; // getEntityHierarchyByEntityIdent

        this.addEntityHierarchy = function(data) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYHIERARCHY]);
            var entityHierarchyPOST = RESTService.post(URI, data);
            return entityHierarchyPOST.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return 0;

                });

        }; // addEntityHierarchy


        this.deleteEntityHierarchy = function(ident) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYHIERARCHY]);

            var entityHierarchyDelete = RESTService.delete(URI, ident);

            return entityHierarchyDelete.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return 0;

                });

        }; // deleteEntityHierarchy

  }]);