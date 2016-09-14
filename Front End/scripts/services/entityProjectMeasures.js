'use strict'

angular.module('App.Services')
    .service('entityProjectMeasuresService', ['RESTService', '$filter', '$global', function(RESTService, $filter, $global) {

        this.getDashboardDials = function(ident) {

        	var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYMEASURES]);

            URI += '?measureLocationIdent=' + ident;

            var entityProjectMeasureGET = RESTService.get(URI);

            return entityProjectMeasureGET.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return [];

                });

        }; // getDashboardDials

        this.getProjectDials = function(projectIdent) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYMEASURES]);

            URI += '?measureLocationIdent=2&projectIdent=' + projectIdent;

            var entityProjectMeasureGET = RESTService.get(URI);

            return entityProjectMeasureGET.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return [];

                });

        }; // getProjectDials

        this.getResourceDials = function(resourceIdent) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYMEASURES]);

            URI += '?measureLocationIdent=3&resourceIdent=' + resourceIdent;

            var entityProjectMeasureGET = RESTService.get(URI);

            return entityProjectMeasureGET.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return [];

                });

        }; // getResourceDials

        this.getOrganizationStructureDials = function(organizationIdent) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYMEASURES]);

            URI += '?measureLocationIdent=4&organizationIdent=' + organizationIdent;

            var entityProjectMeasureGET = RESTService.get(URI);

            return entityProjectMeasureGET.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return [];

                });

        }; // getOrganizationStructureDials

        this.getDialEntityHierarchy = function(ident) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYMEASURES, ident, $global.RESTControllerNames.ORGANIZATIONS]);

            var entityProjectMeasureGET = RESTService.get(URI);

            return entityProjectMeasureGET.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return [];

                });

        }; // getDialEntityHierarchy


        this.getRequirementHierarchy = function(requirementIdent, measureTypeIdent) {

            if (measureTypeIdent){

                var params = [{
                        name: "measureTypeIdent",
                        value: measureTypeIdent
                    }];

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREQUIREMENT, requirementIdent]);
                var entityProjectMeasureGET = RESTService.getWithParams(URI, params);

            } else {

                var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTREQUIREMENT, requirementIdent]);
                var entityProjectMeasureGET = RESTService.get(URI);

            };

            return entityProjectMeasureGET.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return {};

                });

        }; // getRequirementHierarchy


        this.addEditDial = function(data) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYMEASURES]);

            if (data.Ident) {
                var entityProjectMeasureHTTP = RESTService.put(URI, data.Ident, data);
            } else {
                var entityProjectMeasureHTTP = RESTService.post(URI, data);
            };

            return entityProjectMeasureHTTP.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return 0;

                });

        }; // addEditDial


        this.deleteDial = function(ident) {

            var URI = RESTService.getControllerPath([$global.RESTControllerNames.ENTITYMEASURES]);

            var entityProjectMeasureDelete = RESTService.delete(URI, ident);

            return entityProjectMeasureDelete.then(function(pl) {

                    return pl.data;

                },
                function(errorPl) {

                    return 0;

                });

        }; // addEditDial


        // get the max high range value
        this.getMaxRangeValue = function(ranges){

            var maxNumber = null;

            angular.forEach(ranges, function(value, key){

                if (!maxNumber || value.High > maxNumber){

                    maxNumber = value.High;

                };

            });

            return maxNumber;

        };

        // this function gets the percentage ranges so we can draw the % complete to goal
        this.setRangesAsPercentage = function(measure, maxValue){

            angular.forEach(measure.Ranges, function(value, key){

                value.PercentLow = (value.Low / maxValue * 100);
                value.PercentHigh = (value.High / maxValue * 100);

            });


        };

        // Make the display value pretty
        // by adding commas and rounding long decimals
        this.prettyNumber = function (val) {
            // By default, let's just add commas
            var PrettyNumber = $filter('number')(val);

            // Clip the number if it has a lot of decimal places
            var str = val.toString();
            var numChars = str.length;
            var numDecimals = 0;
            // If there's a decimal
            if ( str.indexOf('.') > 0 ) {
                // Determine the number of decimals
                numDecimals = numChars - str.indexOf('.');
                
                if ( numDecimals > 3 ) {
                    // Round to 3 places
                    PrettyNumber = $filter('number')(val, 2);
                }
            }

            return PrettyNumber;
        };


  }]);