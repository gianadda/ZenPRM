'use strict'

angular
    .module('App.ReportsController', ['textAngular'])
    .controller('ReportsController', [
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
        'identity',
        'LookupTablesService',
        'MyProfileService',
        'ChartJs',
        '$stateParams',
        '$state',
        'entityReportService',
        'entityProjectMeasuresService',
        function($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, growl, $window, identity, LookupTablesService, MyProfileService, ChartJs, $stateParams, $state, entityReportService, entityProjectMeasuresService) {

            $scope.loading = true;
            $scope.CurrentReport;
            $scope.ShowList = true;
            $scope.myEditor = {}


            function handleMeasureClick(item, item2) {
                $scope.myEditor.insertContent('<div zen-dial class="ZenDial" measure="getMeasureData(' + item.control.settings.Ident.toString() + ')" allow-edit="false"></div>');
            }

            function handleProfileClick(item, item2) {
                $scope.myEditor.insertContent(item.control.settings.text + ': {{profile.' + item.control.settings.name + '}}');
            }


            $scope.tinymceOptions = {
                body_id: 'Editor',
                content_css: '/assets/css/ZenPRM-' + $rootScope.ZenVersion + '.css',
                element_format: 'html',
                extended_valid_elements: "div[*]",
                fontsize_formats: '11px 13px 15px 18px 21px 24px 30px',
                height: 500,
                image_advtab: true,
                menu: {
                    edit: {
                        title: 'Edit', 
                        items: 'undo redo | cut copy paste pastetext | selectall | searchreplace'
                    },
                    insert: {
                        title: 'Insert', 
                        items: 'link anchor image | hr | charmap nonbreaking | template'
                    },
                    format: {
                        title: 'Format', 
                        items: 'bold italic underline strikethrough superscript subscript | formats | removeformat'
                    },
                    table: {
                        title: 'Table', 
                        items: 'inserttable tableprops deletetable | cell row column'
                    }
                },
                plugins: [
                    'advlist autolink lists link image charmap hr anchor searchreplace code fullscreen',
                    'nonbreaking table contextmenu emoticons template paste textcolor colorpicker imagetools'
                ],
                selector: 'textarea',
                setup: function(editor) {
                    $scope.myEditor = editor;
                    editor.addButton('Measure', {
                        type: 'menubutton',
                        text: 'Measures',
                        icon: false,
                        myEditor: editor,
                        menu: $scope.ResourceMeasuresData
                    });
                    editor.addButton('Profile', {
                        type: 'menubutton',
                        text: 'Profile Data',
                        icon: false,
                        myEditor: editor,
                        menu: $scope.ResourceProfileData
                    });
                },
                style_formats: [
                    {
                        title: 'Table Styles',
                        items: [
                            {
                                title: 'Table Borders',
                                selector: 'table',
                                classes: 'tabled-bordered'
                            },
                            {
                                title: 'Table Stripes',
                                selector: 'table',
                                classes: 'table-striped'
                            },
                            {
                                title: 'Table Row - Active',
                                selector: 'tr',
                                classes: 'active'
                            },
                            {
                                title: 'Table Row - Success',
                                selector: 'tr',
                                classes: 'success'
                            },
                            {
                                title: 'Table Row - Info',
                                selector: 'tr',
                                classes: 'info'
                            },
                            {
                                title: 'Table Row - Warning',
                                selector: 'tr',
                                classes: 'warning'
                            },
                            {
                                title: 'Table Row - Danger',
                                selector: 'tr',
                                classes: 'danger'
                            }
                        ]
                    },
                    {
                        title: 'Paragraph Styles',
                        items: [
                            {
                                title: 'Lead copy',
                                block: 'p',
                                classes: 'lead'
                            },
                            {
                                title: 'Background Primary',
                                block: 'p',
                                classes: 'bg-block bg-primary'
                            },
                            {
                                title: 'Background Success',
                                block: 'p',
                                classes: 'bg-block bg-success'
                            },
                            {
                                title: 'Background Info',
                                block: 'p',
                                classes: 'bg-block bg-info'
                            },
                            {
                                title: 'Background Warning',
                                block: 'p',
                                classes: 'bg-block bg-warning'
                            },
                            {
                                title: 'Background Danger',
                                block: 'p',
                                classes: 'bg-block bg-danger'
                            }
                        ]
                    },
                    {
                        title: 'Text Styles',
                        items: [
                            {
                                title: 'Text Muted',
                                inline: 'span',
                                classes: 'text-muted'
                            },
                            {
                                title: 'Text Primary',
                                inline: 'span',
                                classes: 'text-primary'
                            },
                            {
                                title: 'Text Success',
                                inline: 'span',
                                classes: 'text-success'
                            },
                            {
                                title: 'Text Info',
                                inline: 'span',
                                classes: 'text-info'
                            },
                            {
                                title: 'Text Warning',
                                inline: 'span',
                                classes: 'text-warning'
                            },
                            {
                                title: 'Text Danger',
                                inline: 'span',
                                classes: 'text-danger'
                            }
                        ]
                    }
                ],
                style_formats_merge: true,
                templates: [
                     {
                        title: 'Columns - 1/2',
                        url: '/assets/templates/cols_one-half.html'
                     },
                     {
                        title: 'Columns - 1/3',
                        url: '/assets/templates/cols_one-third.html'
                     },
                     {
                        title: 'Columns - 1/4',
                        url: '/assets/templates/cols_one-fourth.html'
                     },
                     {
                        title: 'Data Table',
                        url: '/assets/templates/table.html'
                     },
                     {
                        title: 'Featured Value',
                        url: '/assets/templates/featured-value.html'
                     },
                     {
                        title: 'Name / Value',
                        url: '/assets/templates/name-value.html'
                     },
                     {
                        title: 'Report Title',
                        url: '/assets/templates/report-title.html'
                     }
                ],
                theme: 'modern',
                toolbar1: 'undo redo | styleselect | bold italic removeformat | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',
                toolbar2: 'fontsizeselect forecolor backcolor emoticons | Profile Measure template code'
            };
            //$scope.ResourceMeasuresData

            $scope.init = function() {
                identity.identity()
                    .then(function() {

                        $scope.MyIdent = identity.getUserIdent();

                        MyProfileService.getProfile($scope.MyIdent).then(function(pl) {

                                $scope.CurrentEntity = pl;
                                $scope.ShowList = true;


                                $scope.ResourceProfileData = [];

                                for (var name in $scope.CurrentEntity.Entity[0]) {
                                    if ($scope.CurrentEntity.Entity[0].hasOwnProperty(name)) {

                                        $scope.ResourceProfileData.push({
                                            text: name.replace(/([A-Z])/g, ' $1').trim(),
                                            name: name,
                                            onclick: handleProfileClick
                                        })

                                    }
                                }


                                entityProjectMeasuresService.getDashboardDials(0).then(function(data) {
                                        $scope.ResourceMeasuresData = data;
                                        $scope.ResourceMeasuresData.map(function(item, index) {
                                            item.onclick = handleMeasureClick;
                                            item.text = item.MeasureName.replace(/([A-Z])/g, ' $1').trim()
                                        })
                                    },
                                    function(errorPl) {
                                        growl.error($global.GetRandomErrorMessage());
                                    });

                                entityReportService.LoadReports().then(function(data) {
                                        $scope.Reports = data.EntityReport;
                                        $scope.ReportsLoaded = true;
                                    },
                                    function(errorPl) {
                                        growl.error($global.GetRandomErrorMessage());
                                        $scope.ReportsLoaded = true;
                                    });

                                $scope.loading = false;


                            },
                            function(errorPl) {
                                growl.error($global.GetRandomErrorMessage());
                                $scope.loading = false;
                            });
                    });
            }

            $scope.save = function() {
                if ($scope.CurrentReport.Ident == 0) {
                    entityReportService.AddEntityReport($scope.CurrentReport.Name1, $scope.CurrentReport.Desc1, $scope.CurrentReport.TemplateHTML, $scope.CurrentReport.PrivateReport).then(function() {
                        $scope.init();
                        growl.success($global.GetRandomSuccessMessage());
                    });
                } else {
                    entityReportService.EditEntityReport($scope.CurrentReport.Ident, $scope.CurrentReport.Name1, $scope.CurrentReport.Desc1, $scope.CurrentReport.TemplateHTML, $scope.CurrentReport.PrivateReport).then(function() {
                        growl.success($global.GetRandomSuccessMessage());
                    });
                }
            }


            $scope.add = function() {
                $scope.ShowList = false;
                $scope.CurrentReport = {};
                $scope.CurrentReport.Ident = 0;
                $scope.CurrentReport.PrivateReport = true;
            }

            $scope.selectReport = function(report) {
                $scope.ShowList = false;
                $scope.CurrentReport = report;
            }

            $scope.cancel = function() {
                $scope.ShowList = true;
                $scope.CurrentReport = {};
            }

            $scope.init();

        }
    ]);
