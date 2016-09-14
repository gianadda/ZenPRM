angular
    .module('App.ProfileController', [])
    .controller('ProfileController', [
        '$scope',
        '$rootScope',
        '$filter',
        '$global',
        'RESTService',
        'growl',
        'identity',
        'MyProfileService',
        '$state',
        '$stateParams',
        'registrationService',
        'delegationService',
        'entityProjectMeasuresService',
        'LookupTablesService',
        'entityService',
        'entityReportService',
        '$modal',
        'ZenValidation',
        function($scope, $rootScope, $filter, $global, RESTService, growl, identity, MyProfileService, $state, $stateParams, registrationService, delegationService, entityProjectMeasuresService, LookupTablesService, entityService, entityReportService, $modal, ZenValidation) {

            $scope.EntityIdent = $stateParams.ident;
            $rootScope.EntityLoaded = false;

            $scope.LoadingMeasures = true;
            $scope.LoadingReports = true;
            $scope.ResourceProjects = [];
            $scope.OrgMeasuresData = [];
            $scope.ResourceMeasuresData = [];

            $scope.userIsSystemAdmin = false;
            $scope.SystemRoles = $global.sysRoleEnum;

            $scope.EntityTypes = LookupTablesService.EntityType;

            $scope.init = function() {

                $scope.Person = null;


                MyProfileService.getProfile($global.BaseUserIdent).then(function(pl) {

                        if (pl.Entity[0].SystemRoleIdent == $global.sysRoleEnum.ZENTEAM) {
                            $scope.userIsSystemAdmin = true;
                        };

                });

                if ($scope.EntityIdent) {

                    MyProfileService.getProfile($scope.EntityIdent).then(function(pl) {

                            $scope.CurrentEntity = pl;
                            $rootScope.CurrentProfileEntityIdent = $scope.CurrentEntity.Entity[0].Ident;
                            $scope.EntityLoaded = true;
                            
                            // we store the image thumbnail, but here we want to be able to display the full sized image
                            $scope.CurrentEntity.Entity[0].ProfilePhoto = $scope.CurrentEntity.Entity[0].ProfilePhoto.replace("_thumb","");
                            
                            $scope.LoadEntityProjects($rootScope.CurrentProfileEntityIdent);
                            $scope.GetMeasuresData();
                            $scope.GetReports();

                            $rootScope.PageTitle = $scope.CurrentEntity.Entity[0].FullName + ' - Profile';
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());

                        });

                } else {

                    MyProfileService.getMyProfile().then(function(pl) {

                            $scope.CurrentEntity = pl;
                            $scope.EntityIdent = $scope.CurrentEntity.Entity[0].Ident;
                            $rootScope.CurrentProfileEntityIdent = $scope.CurrentEntity.Entity[0].Ident;
                            $scope.EntityLoaded = true;
                            
                            $scope.LoadEntityProjects($rootScope.CurrentProfileEntityIdent);
                            $scope.GetMeasuresData();
                            $scope.GetReports();

                            $rootScope.PageTitle = $scope.CurrentEntity.Entity[0].FullName + ' - Profile';
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());

                        });

                }; //if ($stateParams.ident) 

            };

            // Make entity a customer
            $scope.setEntityAsCustomer = function(EntitySystemRoleIdent) {

                var postData = {
                    EntityIdent: $scope.CurrentEntity.Entity[0].Ident,
                    SystemRoleIdent: EntitySystemRoleIdent
                }
                var postEntitySetAsCustomerPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY]) + '/SetAsCustomer', postData);

                postEntitySetAsCustomerPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                        $scope.getProfile($scope.EntityIdent, true);

                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    }
                )

            }

            $scope.accountCanBeClaimed = function() {

                if ($scope.CurrentEntity) {

                    return ($scope.IsCustomer() && !$scope.IsMyProfile($scope.CurrentEntity.Entity[0].Ident) && $scope.CurrentEntity.Entity[0].Person === false && $scope.CurrentEntity.Entity[0].IsInNetwork && $scope.DelegateCount() == 0);

                } else {

                    return false;

                };

            }; //accountCanBeClaimed

            

            $scope.IsCustomer = function() {
                return $global.isCustomer();
            }


            $scope.DelegateCount = function() {

                if ($scope.CurrentEntity && $scope.CurrentEntity.EntityDelegate) {

                    var delegates = $filter('filter')($scope.CurrentEntity.EntityDelegate, { IsDelegateOf: true }, true);

                    if (delegates) {

                        return delegates.length;

                    } else {

                        return 0;
                    };

                };

            };

            $scope.IsActiveDelegate = function() {

                var delegateIdent;
                var userIdent;

                userIdent = identity.getUserIdent();

                if ($scope.CurrentEntity) {
                    delegateIdent = $filter('filter')($scope.CurrentEntity.EntityDelegate, {
                        ToEntityIdent: userIdent
                    }, true)[0];
                }

                return delegateIdent ? true : false;
            }; //IsActiveDelegate


            $scope.CanEdit = function(ident) {
                var bolHide = false;
                if (ident) {

                    ident = ident;
                }
                if (identity.getUserIdent() === ident) {
                    bolHide = true;
                } else if ($scope.IsCustomer()) {
                    bolHide = true;
                }

                return bolHide;

            }

            $scope.IsMyProfile = function(ident) {
                var bolValid = false;
                if (identity.getUserIdent() == ident) {
                    bolValid = true;
                }
                return bolValid;
            }

            $scope.addToNetwork = function(ident) {
                var putData = {
                    Ident: ident,
                    Active: true
                };

                var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ADDENTITYTONETWORK]), putData);

                return editPost.then(function(pl) {
                        var bolSuccess = false;

                        if (pl.data.length > 0) {

                            if (pl.data[0].Ident !== 0) {

                                growl.success($global.GetRandomSuccessMessage());

                                $scope.getProfile($scope.EntityIdent, true);

                            }
                        }

                        return bolSuccess;
                    },
                    function(errorPl) {

                        growl.error($global.GetRandomErrorMessage());
                        return false;
                    });

            }

            $scope.removeFromNetwork = function(ident) {
                var putData = {
                    EntityIdent: ident
                };

                var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.REMOVEENTITYFROMNETWORK]), putData);

                editPost.then(function(pl) {

                        growl.success($global.GetRandomSuccessMessage());
                        $scope.getProfile($scope.EntityIdent, true);

                    },
                    function(errorPl) {

                        if (errorPl.status === 400) {
                            growl.error(errorPl.data);

                        } else {

                            growl.error($global.GetRandomErrorMessage());

                        }

                    });

            };

            $scope.addAsDelegate = function() {

                var postEntityDelegate;
                var postData = {
                    DelegateIdent: $scope.CurrentEntity.Entity[0].Ident
                }
                postEntityDelegate = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYDELEGATE]), postData);

                return postEntityDelegate.then(function(pl) {

                        $scope.getProfile($scope.EntityIdent, true);
                        growl.success('Great! ' + $scope.CurrentEntity.Entity[0].FullName + ' is now setup as your delegate.');
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    }
                );

            };

            $scope.removeAsDelegate = function() {

                var connectionIdent;
                connectionIdent = $filter('filter')($scope.CurrentEntity.EntityDelegate, {
                    ToEntityIdent: $global.UserIdent
                }, true)[0].EntityConnectionIdent;

                var deleteEntityConnectionDelete;
                var postData = {
                    Ident: connectionIdent
                }
                deleteEntityConnectionDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYCONNECTION]), postData);

                return deleteEntityConnectionDelete.then(function(pl) {

                        $scope.getProfile($scope.EntityIdent, true);
                        growl.success('OK - ' + $scope.CurrentEntity.Entity[0].FullName + ' is no longer your delegate.');
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    }
                );

            };

            // $scope.$watch("CurrentEntity", function() {
            //     if ($scope.CurrentEntity) {
            //         $scope.Person = $scope.CurrentEntity.Entity[0].Person;
            //         $rootScope.EntityLoaded = true;
            //     }
            // });

            $scope.IsOrganization = function() {
                //WARNING!!! This doesn't actually check if it's and organization, rather that it's not a Provider
                return !$scope.IsProvider();
            }

            $scope.IsProvider = function() {
                return $scope.Person == true;
            }

            $scope.LoadEntityProjects = function(ident) {

                $scope.ResourceProjects = []; // reset and reload below

                var getEntityProjectsByEntityIdent = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECT]) + '/GetEntityProjectsByEntityIdent', ident);

                getEntityProjectsByEntityIdent.then(function(pl) {
                        $scope.ProjectData = pl.data.EntityProject;

                        angular.forEach($scope.ProjectData, function(value, key) {
                            value.RemainingQuestions = parseInt(value.TotalEntityProjectEntityEntityProjectRequirement) - parseInt(value.TotalEntityProjectEntityEntityProjectAnswers);
                        });

                        // Customers: show bookmarked projects first, sort alpha
                        if ( $scope.IsCustomer() ) {
                            var bookmarked, bookmarked_ordered, normal, normal_ordered;

                            bookmarked = $filter('filter')($scope.ProjectData, {Archived: false, ShowOnProfile: true});
                            if (bookmarked.length > 0) {
                                bookmarked_ordered = $filter('orderBy')(bookmarked, 'Name1');
                            }
                            
                            normal = $filter('filter')($scope.ProjectData, {Archived: false, ShowOnProfile: false});
                            if (normal.length > 0) {
                                normal_ordered = $filter('orderBy')(normal, 'Name1');
                            }
                            
                            $scope.ResourceProjects.push.apply($scope.ResourceProjects, bookmarked_ordered);
                            $scope.ResourceProjects.push.apply($scope.ResourceProjects, normal_ordered);
                        }
                        // Resources: sort by % complete
                        else {
                            var filteredProjects = $filter('filter')($scope.ProjectData, {Archived: false, PrivateProject: false, PercentComplete: '!100.0'});
                            $scope.ResourceProjects = $filter('orderBy')(filteredProjects, '-PercentComplete');
                        }

                        $scope.GetCustomerProjects();
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            $scope.registerEntity = function() {

                if ($scope.CurrentEntity.EntityEmail.length > 0) {

                    registrationService.sendRegistrationEmail($scope.CurrentEntity.Entity[0].Ident).then(function(pl) {

                            growl.success('Great! We\'ve sent an email so that ' + $scope.CurrentEntity.Entity[0].FullName + ' can register and log into ZenPRM.');

                        },
                        function(errorPl) {

                            if (errorPl.data && errorPl.data.entityCanBeRegistered) {

                                growl.error('There are no email addresses on file for this entity. They cannot be registered in ZenPRM until an email address is added.');

                            } else {

                                growl.error($global.GetRandomErrorMessage());

                            };

                        });

                } else {

                    growl.error('There are no email addresses on file for this entity. They cannot be registered in ZenPRM until an email address is added.');

                };

            };

            $scope.claimResource = function() {

                delegationService.claimResource($scope.CurrentEntity.Entity[0].Ident).then(function(pl) {

                        growl.success('Great! You now have access to delegate into and manage this resource\'s account.');

                    },
                    function(errorPl) {

                        if (errorPl.status == 403) {

                            growl.error('Your account cannot be setup to delegate into this account. If you believe this request was denied in error, please contact support.');

                        } else {

                            growl.error($global.GetRandomErrorMessage());

                        };

                    });


            };

            // MEASURES FUNCTIONS //

            // Fetch measure data from end point
            $scope.GetMeasuresData = function(tab) {
                // Set the current tab
                if (tab) {
                    $scope.CurrentTab = tab;
                } else {
                    $scope.CurrentTab = 'organization';
                }

                // Load resource measures (could apply to Providers or Organizations)
                entityProjectMeasuresService.getResourceDials($rootScope.CurrentProfileEntityIdent).then(function(data) {
                        $scope.ResourceMeasuresData = data;

                        // Load organizational measures
                        if ($scope.IsOrganization()) {
                            $scope.GetOrgMeasuresData();
                        } else {
                            $scope.LoadingMeasures = false;
                            $scope.CheckProfileQuality();
                        }
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.ResourceMeasuresData = [];
                        $scope.LoadingMeasures = false;
                    });
            };

            $scope.GetOrgMeasuresData = function() {
                entityProjectMeasuresService.getOrganizationStructureDials($rootScope.CurrentProfileEntityIdent).then(function(data) {
                        $scope.OrgMeasuresData = data;
                        $scope.LoadingMeasures = false;

                        // If there's no org data, activate other tab
                        if ($scope.OrgMeasuresData.length == 0) {
                            $scope.CurrentTab = 'resource';
                        }
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                        $scope.OrgMeasuresData = [];
                        $scope.LoadingMeasures = false;
                    });
            }

            $scope.AddNewMeasure = function() {
                $scope.$broadcast('openNewDialModel', {});
            };

            $scope.MeasureClick = function(measure) {
                $state.go('site.measures', { ident: measure.Ident, tab: 'dials' });
            };


            // ADD RESOURCE TO PROJECT //

            $scope.GetCustomerProjects = function() {

                MyProfileService.getProfile(identity.getUserIdent()).then(function(pl) {
                        $scope.AllCustomerProjects = pl.EntityProject;
                        $scope.CustomerProjects = [];

                        if ( $scope.ProjectData.length > 0 ) { 
                           
                            angular.forEach($scope.AllCustomerProjects, function(value, key) {
                                // Filter out projects that Resource is already assigned to
                                if ( $filter('filter')($scope.ProjectData, { Ident: value.Ident }).length == 0 ) {
                                    $scope.CustomerProjects.push(value);
                                }
                            });

                        }
                        else {
                            $scope.CustomerProjects = $scope.AllCustomerProjects;
                        }
                        
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }

            $scope.AddToThisCustomerProject = {};

            $scope.AddToProject = function() {

                var putData = {
                    EntityProjectIdent: $scope.AddToThisCustomerProject.Ident,
                    EntityIdent: $scope.EntityIdent
                };

                var addToProjectPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPROJECTADDENTITYTOPROJECT]), putData);

                addToProjectPost.then(function (pl) {
                        $scope.AddToThisCustomerProject = {};
                        $scope.init();
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function (errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }; // AddToPRoject

            $scope.getProfile = function(ident, clearCache){

                if (clearCache){
                    MyProfileService.clearProfileCache();
                };

                MyProfileService.getProfile(ident).then(function(pl) {
                        $scope.CurrentEntity = pl;
                    },
                    function(errorPl) {
                        // the following line rejects the promise 

                });

            }; // getProfile

            
            $scope.changeEntityType = function(entityTypeIdent) {

                // if a provider, show the modal
                if (entityTypeIdent == 3){

                    //(Setup) the modal and keep it in scope so we can call functions on it.
                    $scope.ChangeEntityTypeProvider = $modal.open({
                        animation: true,
                        templateUrl: 'ChangeEntityTypeProvider.html',
                        scope: $scope,
                        size: 'md'

                    });

                    //Create an "Ok" function to close the modal.
                    $scope.ChangeEntityTypeProvider.ok = function(npi) {
                        $scope.LoadingResourceChange = true;

                        entityService.changeEntityType($scope.EntityIdent, entityTypeIdent, npi).then(function (data) {

                            if (data && data != "0"){
                                $scope.LoadingResourceChange = false;
                                $scope.ChangeEntityTypeProvider.cancel();
                                growl.success('Success! The resource type has been updated and merged with the existing Global Resource.');
                                $state.go('site.Profile', {ident: data});

                            } else {
                                $scope.LoadingResourceChange = false;
                                $scope.getProfile($scope.EntityIdent, true);
                                $scope.ChangeEntityTypeProvider.cancel();
                                growl.success('Success! The resource type has been updated.');
                            };

                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });
                    }; //ChangeEntityTypeProvider.ok
                    //Create a "Cancel" function to close the modal.
                    $scope.ChangeEntityTypeProvider.cancel = function() {
                        $scope.ChangeEntityTypeProvider.NPI = '';
                        $scope.ChangeEntityTypeProvider.close();
                    };

                    $scope.ChangeEntityTypeProvider.ValidateNPI = function(value) {

                        $scope.ChangeEntityTypeProvider.NPIValid = ZenValidation.ValidNPI(value);
                        return $scope.ChangeEntityTypeProvider.NPIValid;

                    } // ValidateNPI

                } else {

                    entityService.changeEntityType($scope.EntityIdent, entityTypeIdent, '').then(function (pl) {
                            $scope.getProfile($scope.EntityIdent, true);
                            growl.success('Success! The resource type has been updated.');
                        },
                        function (errorPl) {
                            growl.error($global.GetRandomErrorMessage());
                        });

                };



            }; //changeEntityType


            $scope.GetReports = function() {
                

                entityReportService.LoadReports().then(function(pl) {
                        $scope.ReportData = pl.EntityReport;

                        $scope.LoadingReports = false;
                    },
                    function (errorPl) {
                        $scope.LoadingReports = false;
                    });
            }

            $scope.init();
        }
    ])
