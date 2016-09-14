angular
    .module('App', [
        'templates-app',
        'App.Services',
        'App.LoginController',
        'App.UserManagement',

        'App.DashboardController',
        'App.MeasuresController',
        'App.ProfileController',
        'App.EntityDetailsController',
        'App.EntityInsightsController',
        'App.EntityHierarchyController',
        'App.EntityProjectsController',
        'App.EditProfileController',
        'App.AuditHistoryController',
        'App.AddEntityController',
        'App.DelegatesMenuController',

        'App.NotesController',
        'App.ReportController',
        'App.ConnectionController',
        'App.TicketsController',
        'App.RepositoryController',
        'App.ResourcesController',
        'App.ResourcesGridDirective',
        'App.ResourcesInsightsDirective',
        'App.ResourcesMapDirective',
        'App.ResourcesDemographicsDirective',
        'App.ResourcesNetworkDirective',
        'App.ResourcesActivityDirective',
        'App.ResourcesGridGlobalDirective',
        'App.ResourcesMapGlobalDirective',
        'App.ImportController',
        'App.ImportAddPrivate',
        'App.ProjectsController',
        'App.ProjectController',
        'App.ProjectDetailController',

        'App.ReportsController',
        'App.NavigationController',
        'App.OAuthRedirect',
        'App.ProjectNavigationController',
        'App.ProjectQuestionsController',
        'App.ProjectParticipantsController',
        'App.ProjectEditController',
        'App.ProjectAuditController',
        'App.ProjectImportController',
        'App.ProjectRequirementController',
        'App.ProjectRegistration',
        'App.ProjectRegistrationNotValid',
        'App.DelegatesController',

        'App.StyleGuideController',
        'App.HeaderController',
        'App.AccessDenied',
        'App.ChangePasswordController',
        'App.EmailValid',
        'App.EmailNotValid',
        'App.ForgotPasswordController',
        'App.ForgotPasswordNotValid',
        'App.MustChangePasswordController',
        'App.RegisterController',
        'App.RegisterNotValid',
        'App.RegistrationPending',
        'App.NotFound',

        'App.AddDelegateDirective',
        'App.zenCookieWarning',
        'App.zenDatePicker',
        'App.zenDial',
        'App.zenDialModal',
        'App.zenEntityNav',
        'App.zenHierarchyAdd',
        'App.zenNameCheck',
        'App.zenOrgCard',
        'App.zenPhotoUpload',
        'App.zenProject',
        'App.zenPrescriberDetails',
        'App.zenPrescriberSummary',
        'App.zenPhysicianDetails',
        'App.zenPhysicianSummary',
        'App.zenQuestionDrilldown',
        'App.zenReferrals',
        'App.zenResourceName',
        'App.zenResourceCard',
        'App.zenResourceReport',
        'App.zenToneAnalysis',


        'ui.bootstrap',
        'ui.router',
        'ui.validate',
        'theme.form-directives',
        'angular-growl',
        'angular.filter',
        'xeditable',
        'chart.js',
        'as.sortable',
        'pendolytics',
        'ngStorage',
        'nvd3ChartDirectives',
        'angular-clipboard',
        'ui.tinymce'
    ])
    .controller('MainController', ['$scope',
        '$log',
        '$location',
        'identity',
        '$global',
        'LookupTablesService',
        'MyProfileService',
        'RESTService',
        function($scope, $log, $location, identity, $global, LookupTablesService, MyProfileService, RESTService) {

            // Reset default colors
            Chart.defaults.global.colours = [
                '#d47ba7', // pink
                '#5d8ca9', // blue
                '#93d3ea', // sky
                '#e97630', // burnt
                '#e9cc33', // yellow
                '#4ea66a', // green
                '#4d5177', // purple
                '#67c0ce', // teal
                '#94c371', // lime
                '#e29e0a', // orange
                '#af4723', // rust
                '#ce605a' // red
            ];

            //    I left this here in case someone needs it in the future. - WCD
            //    
            //    $scope.$on('$viewContentLoaded', function(event){
            //        $log.debug("This fires when the content loads");
            //    });

            //Returns: the state of the user
            $scope.isLoggedIn = function() {
                return identity.isAuthenticated();
            }

            $scope.isMustChangePassword = function() {
                return identity.mustChangePassword();
            }

            //Intializes App
            $scope.init = function() {
                $log.debug("initializing app.js");


                var loginGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.LOGINGETUSERIDENT]));

                loginGet.then(function(pl) {

                    $global.UserIdent = pl.data[5];
                    $global.BaseUserIdent = pl.data[7];

                });

                // Change style to differentiate sites
                $scope.SiteDifferentiationClass();

                // get CSP
                $scope.getCSP();

            }

            $global.isCustomer = function() {

                return (identity.getRoles()[0] == $global.sysRoleEnum.CUSTOMER ||
                    identity.getRoles()[0] == $global.sysRoleEnum.PROJECTCUSTOMER ||
                    identity.getRoles()[0] == $global.sysRoleEnum.TEAMCUSTOMER ||
                    identity.getRoles()[0] == $global.sysRoleEnum.NETWORKCUSTOMER);
            }

            $global.sysRoleEnum = {
                CUSTOMER: 1,
                ENTITY: 2,
                ZENTEAM: 3,
                PROJECTCUSTOMER: 4,
                TEAMCUSTOMER: 5,
                NETWORKCUSTOMER: 6
            };

            $scope.getCSP = function() {

                //$scope.metaData.CSP = 'default-src \'self\';script-src \'self\' \'unsafe-inline\' \'unsafe-eval\' http://d3accju1t3mngt.cloudfront.net https://d3accju1t3mngt.cloudfront.net https://app.pendo.io https://ajax.googleapis.com https://cdnjs.cloudflare.com https://d3js.org;object-src \'none\';style-src \'self\' \'unsafe-inline\' https://maxcdn.bootstrapcdn.com https://fonts.googleapis.com http://d3accju1t3mngt.cloudfront.net https://d3accju1t3mngt.cloudfront.net https://storage.googleapis.com;img-src \'self\' data: https://app.pendo.io http://d3accju1t3mngt.cloudfront.net https://d3accju1t3mngt.cloudfront.net https://storage.googleapis.com https://cartodb-basemaps-a.global.ssl.fastly.net https://cartodb-basemaps-b.global.ssl.fastly.net https://cartodb-basemaps-c.global.ssl.fastly.net http://localhost:50972 https://zenprmdev.azurewebsites.net https://zenprmalpha.azurewebsites.net https://zenprmprod.azurewebsites.net;media-src \'none\';frame-src \'self\' https://www.youtube.com;font-src \'self\' https://fonts.googleapis.com https://fonts.gstatic.com;connect-src \'self\' ws://localhost:1337 http://localhost:50972 https://maps.googleapis.com https://zenprmdev.azurewebsites.net https://zenprmalpha.azurewebsites.net https://zenprm.ahealthtech.com';
                //   <meta http-equiv="Content-Security-Policy" content="{{ metaData.CSP }}">

                var loginGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.LOGINGETCSP]));

                loginGet.then(function(pl) {

                    var meta = document.createElement('meta');
                    meta.httpEquiv = "Content-Security-Policy";
                    meta.content = pl.headers()['content-security-policy'];
                    document.getElementsByTagName('head')[0].appendChild(meta);

                });


            }; // getCSP

            // Set class to differentiate between local, dev, alpha, or prod
            $scope.SiteDifferentiationClass = function() {
                if (window.location.hostname.indexOf('localhost') >= 0) {
                    $scope.SiteClass = 'local';
                } else if (window.location.hostname.indexOf('dev') >= 0) {
                    $scope.SiteClass = 'dev';
                } else if (window.location.hostname.indexOf('alpha') >= 0) {
                    $scope.SiteClass = 'alpha';
                } else {
                    $scope.SiteClass = 'prod';
                }

            }

            $scope.init();

        }
    ]) //end controller
    .config(['$stateProvider', '$urlRouterProvider', '$compileProvider', function($stateProvider, $urlRouterProvider, $compileProvider) {

        //need to override the default whitelist for protocols allowed by angular
        $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|data|tel):/);

        //All paths in the router should be lowercase
        $urlRouterProvider.rule(function($injector, $location) {
            //what this function returns will be set as the $location.url
            var path = $location.path(),
                normalized = path.toLowerCase();
            if (path != normalized) {
                //instead of returning a new url string, I'll just change the $location.path directly so I don't have to worry about constructing a new url string and so a new state change is not triggered
                $location.replace().path(normalized);
            }
            // because we've returned nothing, no state change occurs
        });



        //Current Version is based on: http://stackoverflow.com/questions/22537311/angular-ui-router-login-authentication

        //TODO:  We could refactor this so that both Nav and Routing are database driven
        //http://blog.brunoscopelliti.com/how-to-defer-route-definition-in-an-angularjs-web-app/
        //http://stackoverflow.com/questions/25494157/angular-ui-router-dynamic-states-get-double-slashes-when-navigated-to-with-ui

        //Other helpful docs: https://github.com/angular-ui/ui-router/wiki/Multiple-Named-Views#view-names---relative-vs-absolute-names

        // Now set up the states
        //Note: 'url': '^/absolutepath', Prefixix with ^ Triggers "Absolute URL Matching", which gets rid of the extra slash caused by the parent-child relationship


        //.state can be abstract and can have children, children are determined using the . notation (eg. site.child)
        //views:  is an object that contains the 3 partial views of the page "content", "navigation", "header"
        //resolve: is where the magic happens, letting us know if the user is authorized to access this view
        //data: is an object that contains the key roles : which is an array of roles that allowed to access the page.
        //url: is the location or path that will resolve to that state.  Children are appened to parents. ^ provides an absolute reference
        //      ie. localhost/#/parent/ | state: "parent" | url: '/parent'
        //          localhost/#/parent/child  | state: "parent.child" | url : '/child'
        //          localhost/#/absoluteurl | state: "site.abs' | url : '^/absoluteurl'  (This is still a child state of parent).


        $stateProvider
            .state('site', {
                abstract: true,
                views: {
                    'content': {
                        templateUrl: 'Dashboard/dashboard.html',
                        controller: 'DashboardController'
                    },
                    'navigation': {
                        templateUrl: 'Navigation/navigation.html',
                        controller: 'NavigationController'
                    },
                    'header': {
                        templateUrl: 'Header/header.html',
                        controller: 'HeaderController'
                    },
                    'projectnavigation@site.ProjectDetail': {
                        templateUrl: 'ProjectNavigation/projectnavigation.html',
                        controller: 'ProjectNavigationController'
                    },
                    'projectnavigation@site.ProjectEdit': {
                        templateUrl: 'ProjectNavigation/projectnavigation.html',
                        controller: 'ProjectNavigationController'
                    },
                    'projectnavigation@site.ProjectParticipants': {
                        templateUrl: 'ProjectNavigation/projectnavigation.html',
                        controller: 'ProjectNavigationController'
                    },
                    'projectnavigation@site.ProjectQuestions': {
                        templateUrl: 'ProjectNavigation/projectnavigation.html',
                        controller: 'ProjectNavigationController'
                    },
                    'projectnavigation@site.ProjectAudit': {
                        templateUrl: 'ProjectNavigation/projectnavigation.html',
                        controller: 'ProjectNavigationController'
                    },
                    'projectnavigation@site.ProjectImport': {
                        templateUrl: 'ProjectNavigation/projectnavigation.html',
                        controller: 'ProjectNavigationController'
                    },
                    'projectnavigation@site.ProjectDetail.Question': {
                        templateUrl: 'ProjectNavigation/projectnavigation.html',
                        controller: 'ProjectNavigationController'
                    }
                },
                resolve: {
                    authorize: ['authorization', '$log',
                        function(authorization, $log) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            return authorization.authorize();
                        }
                    ]
                }
            })
            .state('site.home', {
                url: '/',
                data: {
                    roles: [1, 2, 3, 4, 5, 6]
                },
                resolve: {
                    authorize: ['authorization', 'identity', '$log', '$state', '$global',
                        function(authorization, identity, $log, $state, $global) {
                            console.log(identity);
                            return identity.identity()
                                .then(function() {

                                    if (identity.getRoles()) {
                                        if (identity.getRoles().length > 0) {

                                            if (identity.getRoles()[0] == $global.sysRoleEnum.CUSTOMER ||
                                                identity.getRoles()[0] == $global.sysRoleEnum.PROJECTCUSTOMER ||
                                                identity.getRoles()[0] == $global.sysRoleEnum.TEAMCUSTOMER ||
                                                identity.getRoles()[0] == $global.sysRoleEnum.NETWORKCUSTOMER) {

                                                //Admin
                                                $state.go('site.dashboard');

                                            } else if (identity.getRoles()[0] == $global.sysRoleEnum.ENTITY || identity.getRoles()[0] == $global.sysRoleEnum.ZENTEAM) {
                                                //Physician
                                                $state.go('site.MyProfile');

                                            }
                                        }
                                    } else {}
                                });
                        }
                    ]
                }
            })
            .state('site.dashboard', {
                url: '/dashboard',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Dashboard'
                },
                views: {
                    'content@': {
                        templateUrl: 'Dashboard/dashboard.html',
                        controller: 'DashboardController'
                    }
                }
            })
            .state('site.measures', {
                url: '/measures/:ident/:tab',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Key Performance Measures'
                },
                views: {
                    'content@': {
                        templateUrl: 'Measures/measures.html',
                        controller: 'MeasuresController'
                    }
                }
            })
            .state('site.delegatesMenu', {
                url: '/delegatesmenu',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'My Delegate Accounts'
                },
                views: {
                    'content@': {
                        templateUrl: 'Delegates/delegatesMenu.html',
                        controller: 'DelegatesMenuController'
                    }
                }
            })
            .state('site.MyProfile', {
                url: '/profile',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'My Profile'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/profile.html',
                        controller: 'ProfileController'
                    }
                }
            })
            .state('site.Profile', {
                url: '/profile/:ident',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Profile'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/profile.html',
                        controller: 'ProfileController'
                    }
                }
            })
            .state('site.EditProfile', {
                url: '/editprofile/:ident',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Edit Profile'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/editprofile.html',
                        controller: 'EditProfileController'
                    }
                }
            })
            .state('site.EntityProjects', {
                url: '/resourceprojects/:ident',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Resource Projects'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/projects.html',
                        controller: 'EntityProjectsController'
                    }
                }
            })
            .state('site.EntityDetails', {
                url: '/resourcedetails/:ident',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'My Details'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/details.html',
                        controller: 'EntityDetailsController'
                    }
                }
            })
            .state('site.EntityInsights', {
                url: '/resourceinsights/:ident',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'My Insights'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/insights.html',
                        controller: 'EntityInsightsController'
                    }
                }
            })
            .state('site.AuditHistory', {
                url: '/resourcehistory/:ident',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Resource Audit History'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/audithistory.html',
                        controller: 'AuditHistoryController'
                    }
                }
            })
            .state('site.Repository', {
                url: '/resourcefiles/:entityIdent',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Repository'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/repository.html',
                        controller: 'RepositoryController'
                    }
                }
            })
            .state('site.RepositoryForProject', {
                url: '/resourcefiles/:entityIdent/:projectIdent/:requirementIdent',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Repository'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/repository.html',
                        controller: 'RepositoryController'
                    }
                }
            })
            // .state('site.Connection', {
            //     url: '/connection/:ident/:key',
            //     data: {
            //         roles: [1, 2, 3, 4, 5, 6]
            //     },
            //     views: {
            //         'content@': {
            //             templateUrl: 'Connection/connection.html',
            //             controller: 'ConnectionController'
            //         }
            //     }
            // })
            .state('site.Hierarchy', {
                url: '/resourcehierarchy/:FromEntityIdent',
                data: {
                    roles: [1],
                    PageTitle: 'Organization Structure'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/Hierarchy.html',
                        controller: 'EntityHierarchyController'
                    }
                }
            })
            .state('site.Notes', {
                url: '/resourcenotes/:ident',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Notes'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/notes.html',
                        controller: 'NotesController'
                    }
                }
            })
            .state('site.Reports', {
                url: '/reports',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Reports'
                },
                views: {
                    'content@': {
                        templateUrl: 'Reports/reports.html',
                        controller: 'ReportsController'
                    }
                }
            })
            .state('site.Report', {
                url: '/resourcereport/:reportident/:entityident',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Report'
                },
                views: {
                    'content@': {
                        templateUrl: 'Entity/report.html',
                        controller: 'ReportController'
                    }
                }
            })
            .state('site.AddEntity', {
                url: '/addentity/:NPI',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Add Resource'
                },
                views: {
                    'content@': {
                        templateUrl: 'AddEntity/addentity.html',
                        controller: 'AddEntityController'
                    }
                }
            })
            .state('site.changePassword', {
                url: '/changepassword',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Change Password'
                },
                views: {
                    'content@': {
                        templateUrl: 'AccountMaintenance/ChangePassword/changepassword.html',
                        controller: 'ChangePasswordController'
                    }
                }
            })
            .state('site.GlobalResources', {
                url: '/globalresources/:Tab',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Global Resources'
                },
                views: {
                    'content@': {
                        templateUrl: 'Resources/resources.html',
                        controller: 'ResourcesController'
                    }
                }
            })
            .state('site.Resources', {
                url: '/resources/:Tab',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'My Resources'
                },
                views: {
                    'content@': {
                        templateUrl: 'Resources/resources.html',
                        controller: 'ResourcesController'
                    }
                }
            })
            .state('site.Projects', {
                url: '/projects/:Tab',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Projects'
                },
                views: {
                    'content@': {
                        templateUrl: 'Projects/projects.html',
                        controller: 'ProjectsController'
                    }
                }
            })
            .state('site.Project', {
                url: '/resourceproject/:ident/:entityIdent',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Project'
                },
                views: {
                    'content@': {
                        templateUrl: 'Project/project.html',
                        controller: 'ProjectController'
                    }
                }
            })
            .state('site.Delegates', {
                url: '/delegates',
                data: {
                    roles: [1, 2, 3, 4, 5, 6],
                    PageTitle: 'Delegates'
                },
                views: {
                    'content@': {
                        templateUrl: 'Delegates/delegates.html',
                        controller: 'DelegatesController'
                    }
                }
            })
            .state('site.ProjectDetail', {
                url: '/projectdetail/:ident',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Project Overview'
                },
                views: {
                    'content@': {
                        templateUrl: 'ProjectDetail/projectdetail.html',
                        controller: 'ProjectDetailController'
                    }
                }
            })
            .state('site.ProjectDetail.Question', {
                url: '/question/:questionident/:tab',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Project Question Report'
                },
                views: {
                    'content@': {
                        templateUrl: 'ProjectRequirement/projectrequirement.html',
                        controller: 'ProjectRequirementController'
                    }
                }
            })
            .state('site.ProjectEdit', {
                url: '/projectedit/:ident',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Project Settings'
                },
                views: {
                    'content@': {
                        templateUrl: 'ProjectEdit/projectedit.html',
                        controller: 'ProjectEditController'
                    }
                }
            })
            .state('site.ProjectParticipants', {
                url: '/projectparticipants/:ident',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Project Participants'
                },
                views: {
                    'content@': {
                        templateUrl: 'ProjectParticipants/projectparticipants.html',
                        controller: 'ProjectParticipantsController'
                    },
                    'answers@': {
                        templateUrl: 'Project/project.html',
                        controller: 'ProjectController'
                    }
                }
            })
            .state('site.ProjectAudit', {
                url: '/projectaudit/:ident',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Project Audit History'
                },
                views: {
                    'content@': {
                        templateUrl: 'ProjectAudit/projectaudit.html',
                        controller: 'ProjectAuditController'
                    }
                }
            })
            .state('site.ProjectImport', {
                url: '/projectimport/:ident',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Project Import/Export'
                },
                views: {
                    'content@': {
                        templateUrl: 'ProjectImport/projectimport.html',
                        controller: 'ProjectImportController'
                    }
                }
            })
            .state('site.ProjectQuestions', {
                url: '/projectquestions/:ident',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Project Questions'
                },
                views: {
                    'content@': {
                        templateUrl: 'ProjectQuestions/projectquestions.html',
                        controller: 'ProjectQuestionsController'
                    },
                    'preview@': {
                        templateUrl: 'Project/project.html',
                        controller: 'ProjectController'
                    }
                }
            })
            .state('site.Import', {
                url: '/import',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Import Resources'
                },
                views: {
                    'content@': {
                        templateUrl: 'Import/import.html',
                        controller: 'ImportController'
                    }
                }
            })
            .state('site.ImportAddPrivate', {
                url: '/import/add-private',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Import - Add Private Resources'
                },
                views: {
                    'content@': {
                        templateUrl: 'Import/import-add-private.html',
                        controller: 'ImportAddPrivateController'
                    }
                }
            })
            .state('site.Tickets', {
                url: '/tickets/:ToDoIdent',
                data: {
                    roles: [1, 4, 5, 6],
                    PageTitle: 'Tickets'
                },
                views: {
                    'content@': {
                        templateUrl: 'Tickets/tickets.html',
                        controller: 'TicketsController'
                    }
                }
            })
            .state('login', {
                url: '/login',
                data: {
                    PageTitle: 'Login'
                },
                views: {
                    'login': {
                        templateUrl: 'Login/login.html',
                        controller: 'LoginController'
                    }
                },
                resolve: {
                    authorize: ['identity',
                        function(identity) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            if (identity.isIdentityResolved()) {
                                return identity.logout();
                            }
                        }
                    ]
                }
            })
            .state('registration-pending', {
                url: '/registration-pending',
                data: {
                    PageTitle: 'Registration Pending'
                },
                views: {
                    'login': {
                        templateUrl: 'AccountMaintenance/RegistrationPending/registration-pending.html',
                        controller: 'RegistrationPendingController'
                    }
                },
                resolve: {
                    authorize: ['identity',
                        function(identity) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            if (identity.isIdentityResolved()) {
                                return identity.logout();
                            }
                        }
                    ]
                }
            })
            .state('project-registration', {
                url: '/project-registration/:id',
                data: {
                    PageTitle: 'Registration'
                },
                views: {
                    'login': {
                        templateUrl: 'ProjectRegistration/project-registration.html',
                        controller: 'ProjectRegistrationController'
                    }
                },
                resolve: {
                    authorize: ['identity',
                        function(identity) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            if (identity.isIdentityResolved()) {
                                return identity.logout();
                            }
                        }
                    ]
                }
            })
            .state('oauth-redirect', {
                url: '/oauth-redirect/:id',
                data: {
                    PageTitle: 'Redirecting Sign In'
                },
                views: {
                    'login': {
                        templateUrl: 'Login/oauth-redirect.html',
                        controller: 'OAuthRedirectController'
                    }
                },
                resolve: {
                    authorize: ['identity',
                        function(identity) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            if (identity.isIdentityResolved()) {
                                return identity.logout();
                            }
                        }
                    ]
                }
            })
            .state('project-registration-notvalid', {
                url: '/project-registration-notvalid',
                data: {
                    PageTitle: 'Project Link Not Valid'
                },
                views: {
                    'login': {
                        templateUrl: 'ProjectRegistration/project-registration-notvalid.html',
                        controller: 'ProjectRegistrationNotValidController'
                    }
                },
                resolve: {
                    authorize: ['authorization', '$log',
                        function(authorization, $log) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            return authorization.authorize();
                        }
                    ]
                }
            })
            //Unique case
            .state('mustChangePassword', {
                url: '/mustchangepassword/:guid',
                data: {
                    PageTitle: 'Must Change Password'
                },
                views: {
                    'login': {
                        templateUrl: 'AccountMaintenance/MustChangePassword/mustchangepassword.html',
                        controller: 'MustChangePasswordController'
                    }
                },
                resolve: {
                    authorize: ['authorization', '$log',
                        function(authorization, $log) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            return authorization.authorize();
                        }
                    ]
                }
            })
            .state('register', {
                url: '/register/:id',
                data: {
                    PageTitle: 'Register'
                },
                views: {
                    'login': {
                        templateUrl: 'AccountMaintenance/Register/register.html',
                        controller: 'RegisterController'
                    }
                }
            })
            .state('forgotPassword', {
                url: '/forgotpassword',
                data: {
                    PageTitle: 'Forgot Password'
                },
                views: {
                    'login': {
                        templateUrl: 'AccountMaintenance/ForgotPassword/forgotpassword.html',
                        controller: 'ForgotPasswordController'
                    }
                }
            })
            .state('forgotPasswordNotValid', {
                url: '/forgotpasswordnotvalid',
                data: {
                    PageTitle: 'Password Cannot Be Reset'
                },
                views: {
                    'login': {
                        templateUrl: 'AccountMaintenance/ForgotPasswordNotValid/forgotpasswordnotvalid.html',
                        controller: 'ForgotPasswordNotValid'
                    }
                },
                resolve: {
                    authorize: ['authorization', '$log',
                        function(authorization, $log) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            return authorization.authorize();
                        }
                    ]
                }
            })
            .state('emailvalid', {
                url: '/emailvalid',
                data: {
                    PageTitle: 'Email Confirmed'
                },
                views: {
                    'login': {
                        templateUrl: 'AccountMaintenance/EmailValid/emailvalid.html',
                        controller: 'EmailValidController'
                    }
                },
                resolve: {
                    authorize: ['authorization', '$log',
                        function(authorization, $log) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            return authorization.authorize();
                        }
                    ]
                }
            })
            .state('emailnotvalid', {
                url: '/emailnotvalid',
                data: {
                    PageTitle: 'Email Cannot Be Confirmed'
                },
                views: {
                    'login': {
                        templateUrl: 'AccountMaintenance/EmailNotValid/emailnotvalid.html',
                        controller: 'EmailNotValidController'
                    }
                },
                resolve: {
                    authorize: ['authorization', '$log',
                        function(authorization, $log) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            return authorization.authorize();
                        }
                    ]
                }
            })
            .state('registernotvalid', {
                url: '/registernotvalid',
                data: {
                    PageTitle: 'Registration Link Not Valid'
                },
                views: {
                    'login': {
                        templateUrl: 'AccountMaintenance/RegisterNotValid/registernotvalid.html',
                        controller: 'RegisterNotValidController'
                    }
                },
                resolve: {
                    authorize: ['authorization', '$log',
                        function(authorization, $log) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            return authorization.authorize();
                        }
                    ]
                }
            })
            .state('site.notfound', {
                url: '/404',
                data: {
                    PageTitle: 'Page Not Found'
                },
                views: {
                    'content@': {
                        templateUrl: 'AccountMaintenance/NotFound/notfound.html',
                        controller: 'NotFoundController'
                    }
                },
                resolve: {
                    authorize: ['authorization', '$log',
                        function(authorization, $log) {
                            //$log.debug("Resolve authorization", authorization.authorize());
                            return authorization.authorize();
                        }
                    ]
                }
            })
            .state('accessdenied', {
                url: '/accessdenied',
                data: {
                    PageTitle: 'Access Denied'
                },
                views: {
                    'login': {
                        templateUrl: 'AccountMaintenance/AccessDenied/accessdenied.html',
                        controller: 'AccessDeniedController'
                    }
                },
                resolve: {
                    authorize: ['identity',
                        function(identity) {
                            //Log them out because they tried to navigate somewhere they shouldn't be
                            if (identity.isIdentityResolved()) {
                                return identity.logout();
                            }
                        }
                    ]
                }
            })
            .state('site.styleguide', {
                url: '/styleguide',
                data: {
                    PageTitle: 'Style Guide'
                },
                views: {
                    'content@': {
                        templateUrl: 'StyleGuide/styleGuide.html',
                        controller: 'StyleGuideController'
                    }
                }
            });

        $urlRouterProvider.otherwise("/login");
    }])
    //The UI Router functions fire events depending on where in a state transition they are, we listen for them here.
    //$stateChangeStart is where we check to make sure the user is authorized to see the next view
    //$stateNotFound is for error handling
    //$stateChangeError is for error handling
    .run(['$rootScope', '$log', '$state', '$stateParams', 'authorization', 'identity', 'LookupTablesService', '$global', function($rootScope, $log, $state, $stateParams, authorization, identity, LookupTablesService, $global) {

        $rootScope.$on('$stateChangeStart', function(event, toState, toStateParams, fromState, fromStateParams) {
            //   $log.debug("$stateChangeStart: ", event, " from: ", fromState, " to: ", toState);
            //track the state the user wants to go to; authorization service nees this

            $rootScope.toState = toState;
            $rootScope.toStateParams = toStateParams;

            if ($global.UserIsLoggedOut === true && toState.name !== 'login' && $global.UserIdent) {

                event.preventDefault();
                $state.go('login');
                $global.UserIsLoggedOut = false;
            }

            //if their identity is resolved, do an authorization check immediately
            if (identity.isIdentityResolved()) {
                authorization.authorize().then(
                    function(pl) {
                        //$log.debug("$stateChangeStart Authorization Success")
                    },
                    function(err) {
                        //$log.debug("Authorization Fail")
                    }
                );
            } else {
                //$log.debug("$stateChangeStart identity is not resolved");
            }
        })

        $rootScope.$on('$stateChangeSuccess', function(event, toState) {
            if (toState.data && toState.data.PageTitle) {
                $rootScope.PageTitle = toState.data.PageTitle;
            } else {
                $rootScope.PageTitle = 'Amazingly Simple';
            }
        })

        $rootScope.$on('$stateNotFound', function(event, unfoundState, fromState, fromParams) {
            $log.debug("$stateNotFound: ", event, " to: ", unfoundState.to, " from: ", fromState);
        })

        $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams, error) {
            $log.debug("$stateChangeError to: ", toState, " from: ", fromState, " error: ", error);
        });
    }])

.config(['growlProvider', function(growlProvider) {
        //http://janstevens.github.io/angular-growl-2/
        growlProvider.globalPosition('bottom-center');
        growlProvider.globalDisableIcons(true);
        growlProvider.globalTimeToLive({
            success: 3000,
            error: 5000,
            warning: 3000,
            info: 3000
        });
    }])
    .run(function() {
        FastClick.attach(document.body);
    })
    .run(function(editableOptions) {
        editableOptions.theme = 'bs3';
    })
    .filter('orderObjectBy', function() {
        return function(items, field, reverse) {
            var filtered = [];
            angular.forEach(items, function(item) {
                filtered.push(item);
            });
            filtered.sort(function(a, b) {
                return (a[field] > b[field] ? 1 : -1);
            });
            if (reverse) filtered.reverse();
            return filtered;
        };
    });
