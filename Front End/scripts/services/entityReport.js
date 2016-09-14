'use strict'

angular.module('App.Services')
    .service('entityReportService', ['RESTService', '$global', function(RESTService, $global) {

        this.AddEntityReport = function(reportName1, reportDesc1, reportTemplateHTML, reportPrivateReport) {

            var putData = {
                Name1: reportName1,
                Desc1: reportDesc1,
                TemplateHTML: reportTemplateHTML,
                PrivateReport: reportPrivateReport,
                Active: true
            };

            var AddEntityReportPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYREPORT]), putData);

            return AddEntityReportPost.then(function(pl) {
                    return pl;
                },
                function(errorPl) {
                    return errorPl;
                });
        }; // AddEntityReport

        this.DeleteEntityReport = function(entityReportIdent) {

            var deleteEntityInteractionDelete;
            var postData = {
                EntityReportIdent: entityReportIdent
            };

            deleteEntityReportDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYREPORT]), postData);

            return deleteEntityReportDelete.then(function(pl) {
                    return pl;
                },
                function(errorPl) {
                    return errorPl;

                }
            );

        }; // DeleteEntityReport


        this.EditEntityReport = function(entityReportIdent, reportName1, reportDesc1, reportTemplateHTML, reportPrivateReport) {

            var putData = {
                Name1: reportName1,
                Desc1: reportDesc1,
                TemplateHTML: reportTemplateHTML,
                PrivateReport: reportPrivateReport
            };

            var EditEntityReportPut = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYREPORT]), entityReportIdent, putData);

            return EditEntityReportPut.then(function(pl) {
                    return pl;
                },
                function(errorPl) {
                    return errorPl;
                });
        }; // EditEntityReport

        this.LoadReports = function() {

            var getReports = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYREPORT]));

            return getReports.then(function(pl) {
                    return pl.data;
                },
                function(errorPl) {
                    return errorPl;
                });
        }; // LoadReports

        this.getEntityReport = function(EntityReportIdent) {

            var getReports = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYREPORT]), EntityReportIdent);

            return getReports.then(function(pl) {
                    return pl.data;
                },
                function(errorPl) {
                    return errorPl;
                });

        };



    }]);
