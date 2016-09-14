'use strict'

angular
    .module('App.ImportController', [])
    .controller('ImportController', [
    '$scope',
    '$rootScope',
    '$log',
    '$filter',
    '$timeout',
    '$http',
    '$global',
    'RESTService',
    'growl',
    '$window',
    'LookupTablesService',
    'MyProfileService',
    '$stateParams',
function ($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, growl, $window, LookupTablesService, MyProfileService, $stateParams) {



            $scope.init = function () {

                //Find the Physician Upload holder so we can attach events
                $scope.ImportHolder = document.getElementById('ImportHolder');

                $scope.ImportLoading = false;
                $scope.dropImportActive = false;
                $scope.UploadCount = 0;

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
                    readImportFile(e.dataTransfer.files);

                }

            }


            function readImportFile(files) {


                if (files.length > 0) {

                    var reader = new FileReader();

                    //Setup the "onload" even to fire after the file is read into memory
                    reader.onload = function (event) {

                        $scope.ImportedData = [];
                        var UploadCountObject = csvJSON(event.target.result.replace(/\r\n|\r/g, '\n'), true).filter(function (n) {
                            return n.NPI !== '';
                        });

                        if (UploadCountObject.length > 0) {
                            $scope.UploadCount = UploadCountObject.length;
                        }


                        //Validate Data:
                        if ($scope.UploadCount > 0) {

                            if (UploadCountObject[0].hasOwnProperty('NPI')) {

                                $scope.CSVofIdents = Array.prototype.map.call(UploadCountObject, function (x) {
                                    return x.NPI;
                                }).join(',')

                                $scope.ImportLoading = false;
                                $scope.dropImportActive = false;
                                $scope.$apply();

                            } else {

                                $scope.UploadCount = 0;
                                $scope.CSVofIdents = '';
                                $scope.ImportLoading = false;
                                $scope.dropImportActive = false;
                                $scope.$apply();
                                growl.error('You are missing one of the required fields.');


                            }

                        } else {

                            $scope.UploadCount = 0;
                            $scope.CSVofIdents = '';
                            $scope.ImportLoading = false;
                            $scope.dropImportActive = false;
                            $scope.$apply();
                            growl.error('There are no records in the file.');


                        }



                    };

                    //Read the file.
                    reader.readAsText(files[0]);

                }


            };

            //turn a CSV string into a JSON string
            function csvJSON(csv, asObject) {

                var lines = csv.split("\n");
                var result = [];
                var headers = lines[0].split(",");

                for (var i = 1; i < lines.length; i++) {
                    var obj = {};
                    var currentline = lines[i].split(",");
                    for (var j = 0; j < headers.length; j++) {
                        obj[headers[j]] = currentline[j];
                    }
                    result.push(obj);
                }

                if (asObject) {
                    return result; //JavaScript object
                } else {
                    return JSON.stringify(result); //JSON
                }

            };


            $scope.Commit = function () {

                if ($scope.CSVofIdents) {

                    var putData = {
                        NPICSV: $scope.CSVofIdents,
                        Active: true
                    };

                    var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ADDENTITYTONETWORKBYCSV]), putData);

                    return editPost.then(function (pl) {
                            var bolSuccess = false;

                            if (pl.data.length > 0) {

                                growl.success($global.GetRandomSuccessMessage());

                                $scope.UploadCount = 0;
                                $scope.CSVofIdents = '';
                                $scope.ImportedData = pl.data;
                                bolSuccess = true;


                            }

                            return bolSuccess;
                        },
                        function (errorPl) {

                            growl.error($global.GetRandomErrorMessage());
                            return false;
                        });
                }
            }


            $scope.init();

}]);