'use strict'

angular
    .module('App.ImportAddPrivate', [])
    .controller('ImportAddPrivateController', [
    '$scope',
    '$log',
    '$filter',
    '$timeout',
    '$global',
    'RESTService',
    'growl',
    'importFileService',
function ($scope, $log, $filter, $timeout, $global, RESTService, growl, importFileService) {

        $scope.init = function () {

            //Find the Physician Upload holder so we can attach events
            $scope.ImportHolder = document.getElementById('ImportHolder');
            $scope.ImportData = {};
            $scope.ImportResources = [];
            $scope.ImportColumns = [];

            $scope.HeadersProcessed = false;
            $scope.VerificationComplete = false;
            $scope.ImportComplete = false;
            $scope.ImportLoading = false;
            $scope.dropImportActive = false;
            $scope.UploadCount = 0;

            $scope.getImportColumns();

            $scope.ImportHolder.ondragover = function () {
                $scope.dropImportActive = true;
                $scope.$apply();
                return false;
            };
            $scope.ImportHolder.ondragleave = function () {
                $scope.dropImportActive = false;
                $scope.$apply();
                return false;
            };
            $scope.ImportHolder.ondragend = function () {
                $scope.dropImportActive = false;
                $scope.$apply();
                return false;
            };
            $scope.ImportHolder.ondrop = function (e) {
                e.preventDefault();
                $scope.ImportLoading = true;
                $scope.$apply();

                if (e.dataTransfer.files.length == 1) {

                    $scope.FileToUpload = e.dataTransfer.files[0];
                    $scope.processFile();
                };

            };

        }; // init

        $scope.getImportColumns = function(){

            importFileService.getImportColumns().then(function(data) {

                $scope.ImportColumns = data;
            
            });

        }; //getImportColumns

        $scope.processFile = function(){

            $scope.ImportData.FileHeaders = [];

            Papa.parse($scope.FileToUpload, {
                header: true,
                worker: false,
                dynamicTyping: false,
                skipEmptyLines: true,
                delimiter: ",",  // auto detect breaks once we introduce the delimited options within the question
                error: function(err, file, inputElem, reason) {
                    console.log(err);
                },
                complete: function(results, file) {

                    results.meta.fields.forEach(function(value, index) {

                        var header = {};
                        header.label = value;

                        var column;
                        column = $filter('filter')($scope.ImportColumns, {Label: value}, true);

                        if (!column || column.length == 0){
                            column = $filter('filter')($scope.ImportColumns, {ColumnName: value}, true);
                        };

                        if (column && column.length > 0){
                            header.ColumnIdent = column[0].Ident;
                            header.ColumnLabel = column[0].Label;
                        } else {
                            header.ColumnIdent = 0;
                        };

                        $scope.ImportData.FileHeaders.push(header);

                    }); // for Each File Headers

                    // store file data in memory
                    $scope.ImportData.data = results.data;

                    $scope.HeadersProcessed = true;
                    $scope.ImportLoading = false;

                    $scope.$apply();

                } // complete
            });

        };

        $scope.VerifyFile = function () {

            $scope.ImportResources = [];
            $scope.ImportLoading = true;

            var ImportColumns = [];

            $scope.ImportData.FileHeaders.forEach(function(value, index) {

                if (value.ColumnIdent > 0){

                    ImportColumns.push(value);

                };

            });

            $scope.ImportData.data.forEach(function(value, index) {

                var entity = {};

                //console.log('Entity:' + value);

                ImportColumns.forEach(function(innerValue, innerIndex) {

                    var columnName = $filter('filter')($scope.ImportColumns, {Ident: innerValue.ColumnIdent}, true)[0].ColumnName;
                    entity[columnName] = value[innerValue.label];

                    //console.log('column: ' + innerValue);

                }); // for Each File Headers

                $scope.ImportResources.push(entity);

            }); // for resources.data

            importFileService.importResourcesVerifyEntity($scope.ImportResources).then(function(data) {

                $scope.ImportResources = data;
                $scope.VerificationComplete = true;
                $scope.ImportLoading = false;
            
            });

        }; // VerifyFile

        $scope.Commit = function () {

            $scope.ImportLoading = true;
            var resources = [];

            // only send the selected resources to the API
            $scope.ImportResources.forEach(function(value, index) {

                if (value.selected){

                    resources.push(value);

                };

            });

            importFileService.importResources(resources).then(function(data) {

                $scope.ImportResources = data;
                $scope.ImportComplete = true;
                $scope.ImportLoading = false;
            
            });

        }; // Commit

        $scope.UnMapResource = function(resource){

            // take the current import record and clear the linked info to an existing resource
            resource.Ident = 0;
            resource.selected = true;
            resource.ImportAction = 'Add';
            resource.MatchCount = 0;

        }; // UnMap Resource

        $scope.updateImportStatus = function(resource, importAction, updateMatchCount){

            resource.ImportAction = importAction;

            if (updateMatchCount){
                resource.MatchCount += 1;
            };

        }; // updateImportStatus

        $scope.addColumnLabelToHeader = function(header){
            
            var label = $filter('filter')($scope.ImportColumns, {Ident: header.ColumnIdent}, true)[0].Label;

            header.ColumnLabel = label;
        };

        $scope.init();

}]);