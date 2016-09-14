angular
    .module('App.EditProfileController', ['ngTagsInput', 'toggle-switch', 'xeditable'])
    .controller('EditProfileController', [
        '$scope',
        '$rootScope',
        '$filter',
        '$http',
        '$sce',
        '$global',
        'RESTService',
        'growl',
        'entityService',
        'LookupTablesService',
        'MyProfileService',
        '$stateParams',
        '$state',
        'ZenValidation',
        'registrationService',
        'entityNetworkService',
        'entityHierarchyService',
        'identity',
        function($scope, $rootScope, $filter, $http, $sce, $global, RESTService, growl, entityService, LookupTablesService, MyProfileService, $stateParams, $state, ZenValidation, registrationService, entityNetworkService, entityHierarchyService, identity) {

            $scope.ZenValidation = ZenValidation;
            $scope.LookupTables = LookupTablesService;
            $scope.SavedData = {};
            $scope.EntityType = null;
            $scope.OriginalNPI = '';
            $scope.Person = null;
            $scope.NPIValid = false;
            $scope.emailAlert = '';
            $scope.newEmail = {};
            $scope.loading = true;

            $scope.networkOrgs = [];
            $scope.hierarchyTags = {};

            $scope.EntityIdent = $stateParams.ident;


            var init = function() {

                if ($scope.EntityIdent) {

                    MyProfileService.getProfile($scope.EntityIdent).then(function(pl) {
                            $scope.Profile = pl.Entity[0];

                            $rootScope.CurrentProfileEntityIdent = $scope.Profile.Ident

                            if ($scope.Profile.BirthDate == '01/01/1900') {
                                $scope.Profile.BirthDate = null;
                            }
                            if ($scope.Profile.DEANumberExpirationDate == '01/01/1900') {
                                $scope.Profile.DEANumberExpirationDate = null;
                            }
                            if ($scope.Profile.PrescriptionLicenseNumberExpirationDate == '01/01/1900') {
                                $scope.Profile.PrescriptionLicenseNumberExpirationDate = null;
                            }
                            if ($scope.Profile.TaxIDNumberExpirationDate == '01/01/1900') {
                                $scope.Profile.TaxIDNumberExpirationDate = null;
                            }
                            //console.log($scope.Profile.BirthDate);
                            $scope.Person = pl.Entity[0].Person;

                            $scope.Taxonomies = pl.Taxonomy;
                            $scope.Payors = pl.Payor;
                            $scope.Languages = pl.Language;
                            $scope.Degrees = pl.Degree;
                            $scope.Services = pl.Services;
                            $scope.Specialities = pl.Speciality;
                            $scope.EntityType = $scope.Profile.EntityType;
                            $scope.EntitySystem = pl.EntitySystem;
                            $scope.EntityLicense = pl.EntityLicense;
                            $scope.EntityOtherID = pl.EntityOtherID;
                            $scope.EntityEmail = pl.EntityEmail;

                            $rootScope.PageTitle = $scope.Profile.FullName + ' - Edit Details';

                            // Set up hierarchy
                            $scope.setupEntityHierarchy();

                            $scope.loading = false;

                        },
                        function(errorPl) {
                            $scope.loading = false;
                        });

                }
                else {
                    $state.go('site.notfound');
                }

            } //init


            $scope.SaveData = function() {
                $scope.SavedData = $scope.Profile;
                
                if ($scope.Profile) {
                    if ($scope.Profile.BirthDate == null) {
                        $scope.Profile.BirthDate = '1/1/1900';
                    }

                    var stateText = $filter('filter')(LookupTablesService.States, { Ident: $scope.SavedData.PrimaryStateIdent }, true)[0].Name1;

                    var addressSearch = $scope.SavedData.PrimaryAddress1 + ", " + $scope.SavedData.PrimaryCity + ", " + stateText + " " + $scope.SavedData.PrimaryZip;

                    var getgoogleMapsAPI = {
                        method: 'GET',
                        url: encodeURI('https://maps.googleapis.com/maps/api/geocode/json?address=' + addressSearch)
                    };

                    $http(getgoogleMapsAPI).then(function(pl) {

                            if (pl.data && pl.data.results.length > 0 && pl.data.results[0].geometry) {

                                var lat = pl.data.results[0].geometry.location.lat;
                                var lng = pl.data.results[0].geometry.location.lng;

                                $scope.SavedData.Latitude = lat;
                                $scope.SavedData.Longitude = lng;

                            };

                            $scope.completeEntitySave();

                        },
                        function(errorPl) {

                            $scope.completeEntitySave();

                        });
                }
            }

            $scope.completeEntitySave = function() {

                var editProfilePut = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY]), $scope.SavedData);

                editProfilePut.then(function(pl) {

                        MyProfileService.clearProfileCache(); // need to indicate that changes have been made and need to refresh from server, so dump local cache
                        growl.success($global.GetRandomSuccessMessage());
                        $state.go('site.EntityDetails', {
                            ident: $rootScope.CurrentProfileEntityIdent
                        })
                    },
                    function(errorPl) {

                        growl.error($global.GetRandomErrorMessage());
                    });

            };


            /* -------------------------------- */
            /* NPI */
            /* -------------------------------- */


            //NPI click to edit code, validate and save code
            $scope.NPIeditorEnabled = false;

            $scope.enableNPIEditor = function() {
                $scope.OriginalNPI = $scope.Profile.NPI;
                $scope.NPIeditorEnabled = true;
            };

            $scope.disableNPIEditor = function() {
                $scope.Profile.NPI = $scope.OriginalNPI
                $scope.NPIeditorEnabled = false;
            };

            $scope.ValidateNPI = function($value) {

                if ($value === '') {
                    //Todo, fix ui-validation, shouldn't need this place holder NPIValid.
                    $scope.NPIValid = true;
                    return true;
                } else {
                    $scope.NPIValid = ZenValidation.ValidNPI($value);
                    return ZenValidation.ValidNPI($value);
                };
            }

            $scope.saveNPI = function() {
                $scope.NPIeditorEnabled = !$scope.NPIeditorEnabled;
            }

            $scope.EditEntityNPI = function() {

                var postEntityNPIPost;
                var postData = {
                    EntityIdent: $scope.Profile.Ident,
                    NPI: $scope.Profile.NPI
                }
                postEntityNPIPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYNPI]), postData);

                return postEntityNPIPost.then(function(pl) {
                        if (pl.data) {
                            growl.success($global.GetRandomSuccessMessage());
                            $scope.NPIeditorEnabled = false;
                        } else {
                            growl.error('The NPI you have entered already exists in the system.');
                        };
                    },
                    function(errorPl) {
                        if (errorPl && errorPl.data === false) {
                            growl.error('The NPI you have entered already exists in the system.');
                        } else {
                            growl.error($global.GetRandomErrorMessage());
                        }
                    }
                );
            };


            /* -------------------------------- */
            /* PAYORS */
            /* -------------------------------- */


            $scope.RemovePayor = function(tag) {
                var putData = {
                    PayorIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident
                };

                var editDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPAYOR]), putData);

                editDelete.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            $scope.AddPayor = function(tag) {

                var putData = {
                    PayorIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident,
                    Active: true
                };

                var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYPAYOR]), putData);

                editPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }


            /* -------------------------------- */
            /* LANGUAGES */
            /* -------------------------------- */


            $scope.RemoveLanguage = function(tag) {
                var putData = {
                    LanguageIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident
                };

                var editDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYLANGUAGE]), putData);

                editDelete.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            $scope.AddLanguage = function(tag) {

                var putData = {
                    LanguageIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident,
                    Active: true
                };

                var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYLANGUAGE]), putData);

                editPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }


            /* -------------------------------- */
            /* DEGREES */
            /* -------------------------------- */


            $scope.RemoveDegree = function(tag) {
                var putData = {
                    DegreeIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident
                };

                var editDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYDEGREE]), putData);

                editDelete.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            $scope.AddDegree = function(tag) {

                var putData = {
                    DegreeIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident,
                    Active: true
                };

                var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYDEGREE]), putData);

                editPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }


            /* -------------------------------- */
            /* SPECIALTIES */
            /* -------------------------------- */


            $scope.RemoveSpeciality = function(tag) {
                var putData = {
                    SpecialityIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident
                };

                var editDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSPECIALITY]), putData);

                editDelete.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            $scope.AddSpeciality = function(tag) {

                var putData = {
                    SpecialityIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident,
                    Active: true
                };

                var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSPECIALITY]), putData);

                editPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }


            /* -------------------------------- */
            /* TAXONOMIES */
            /* -------------------------------- */


            $scope.RemoveTaxonomy = function(tag) {
                var putData = {
                    TaxonomyIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident
                };

                var editDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTAXONOMY]), putData);

                editDelete.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            $scope.AddTaxonomy = function(tag) {

                var putData = {
                    TaxonomyIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident,
                    Active: true
                };

                var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYTAXONOMY]), putData);

                editPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }


            /* -------------------------------- */
            /* SERVICES */
            /* -------------------------------- */


            $scope.RemoveService = function(tag) {
                var putData = {
                    ServicesIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident
                };

                var editDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSERVICES]), putData);

                editDelete.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            $scope.AddService = function(tag) {

                var putData = {
                    ServicesIdent: tag.Ident,
                    EntityIdent: $scope.Profile.Ident,
                    Active: true
                };

                var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSERVICES]), putData);

                editPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            }

            $scope.loadTags = function(query, datasource) {
                return $filter('orderBy')($filter('filter')(datasource, query), "Name1");
            };


            /* -------------------------------- */
            /* SYSTEM */
            /* -------------------------------- */


            $scope.showSystemType = function(system) {
                if (system.SystemTypeIdent !== 0) {
                    var selected = $filter('filter')(LookupTablesService.SystemType, {
                        Ident: system.SystemTypeIdent
                    }, true);
                    return selected.length ? selected[0].Name1 : 'Not set';
                } else {
                    return system.SystemType || 'Not set';
                }
            };

            $scope.saveSystem = function(data, index) {

                var putData = {
                    EntityIdent: $scope.Profile.Ident,
                    SystemTypeIdent: data.SystemType,
                    Name1: data.SystemName,
                    InstalationDate: data.SystemInstallationDate,
                    GoLiveDate: data.SystemGoLiveDate,
                    DecomissionDate: data.SystemDecommissionDate,
                    Active: true
                };

                var addPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSYSTEM]), putData);

                addPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());

                        putData.Ident = pl.data[0].Ident;

                        $scope.EntitySystem.push(putData);

                        $scope.Profile.SystemName = undefined;
                        $scope.Profile.SystemType = undefined;
                        $scope.Profile.SystemInstallationDate = undefined;
                        $scope.Profile.SystemGoLiveDate = undefined;
                        $scope.Profile.SystemDecommissionDate = undefined;
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }

            $scope.removeSystem = function(ident, index) {
                var putData = {
                    Ident: ident
                };

                var editDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSYSTEM]), putData);

                editDelete.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                        $scope.EntitySystem.splice(index, 1);
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            };


            /* -------------------------------- */
            /* LICENSE */
            /* -------------------------------- */


            $scope.showState = function(license) {
                if (license.StatesIdent !== 0) {
                    var selected = $filter('filter')(LookupTablesService.States, {
                        Ident: license.StatesIdent
                    }, true);
                    return selected.length ? selected[0].Name1 : 'Not set';
                } else {
                    return license.State || 'Not set';
                }
            };

            $scope.saveLicense = function(data, index) {

                var putData = {
                    EntityIdent: $scope.Profile.Ident,
                    StatesIdent: data.LicenseStatesIdent,
                    LicenseNumber: data.LicenseNumber,
                    LicenseNumberExpirationDate: data.LicenseDate,
                    Active: true
                };

                var addPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYLICENSE]), putData);

                addPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                        putData.Ident = pl.data[0].Ident;
                        $scope.EntityLicense.push(putData);
                        $scope.Profile.LicenseStatesIdent = undefined;
                        $scope.Profile.LicenseNumber = undefined;
                        $scope.Profile.LicenseDate = undefined;
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            };

            $scope.removeLicense = function(ident, index) {
                var putData = {
                    Ident: ident
                };

                var editDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYLICENSE]), putData);

                editDelete.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                        $scope.EntityLicense.splice(index, 1);
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            };


            /* -------------------------------- */
            /* OTHER ID */
            /* -------------------------------- */


            $scope.saveOtherID = function(data, index) {

                var putData = {
                    EntityIdent: $scope.Profile.Ident,
                    IDType: data.OtherIDType,
                    IDNumber: data.OtherIDNumber,
                    Active: true
                };

                var addPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYOTHERID]), putData);

                addPost.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                        putData.Ident = pl.data.Ident;
                        $scope.EntityOtherID.push(putData);
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });

            }


            $scope.removeOtherID = function(ident, index) {
                var putData = {
                    Ident: ident
                };

                var editDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYOTHERID]), putData);

                editDelete.then(function(pl) {
                        growl.success($global.GetRandomSuccessMessage());
                        $scope.EntityOtherID.splice(index, 1);
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    });
            };


            /* -------------------------------- */
            /* EMAILS */
            /* -------------------------------- */


            $scope.TrustEmailHTML = function(email) {
                return $sce.trustAsHtml(email);
            };


            $scope.AddEntityEmail = function() {

                entityService.addEntityEmail($scope.Profile.Ident,$scope.newEmail.email).then(function(data) {
                        if (data && data.IsUnique) {
                            $scope.newEmail = {};
                            $scope.EntityEmail.push(data.email);
                            growl.success($global.GetRandomSuccessMessage());
                            $scope.emailAlert = ''; //clear any errors just in case
                        } else {
                            
                            var message = 'The email address you have entered already exists in the system.';

                            // if the user is a customer, display additional info regarding the user profile
                            if ($scope.IsCustomer()){

                                message += ' It is currently assigned to ' + data.EntityFullName + '. ';
                                message += 'You can view their profile <a href="#/profile/' + data.EntityIdent + '"><u>here</u></a>.';

                            };

                            // force the user to close this since there is a link in the text
                            $scope.emailAlert = $scope.TrustEmailHTML(message);
                        };
                    });
            };


            $scope.markEmailAsNotify = function(entityEmail, index) {

                var entityEmailPut;
                var putData = {
                    Ident: entityEmail.Ident,
                    EntityIdent: entityEmail.EntityIdent,
                    Email: entityEmail.Email,
                    Notify: true,
                    Verified: entityEmail.Verified,
                    VerifiedASUserIdent: entityEmail.VerifiedASUserIdent,
                    Active: true
                }
                entityEmailPut = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYEMAIL]), putData);

                return entityEmailPut.then(function(pl) {
                        $scope.newEmail = {};
                        $scope.EntityEmail[index].Notify = true;
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    }
                );
            };


            $scope.markEmailAsNonNotify = function(entityEmail, index) {

                var entityEmailPut;
                var putData = {
                    Ident: entityEmail.Ident,
                    EntityIdent: entityEmail.EntityIdent,
                    Email: entityEmail.Email,
                    Notify: false,
                    Verified: entityEmail.Verified,
                    VerifiedASUserIdent: entityEmail.VerifiedASUserIdent,
                    Active: true
                }
                entityEmailPut = RESTService.put(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYEMAIL]), putData);

                return entityEmailPut.then(function(pl) {
                        $scope.newEmail = {};
                        $scope.EntityEmail[index].Notify = false;
                        growl.success($global.GetRandomSuccessMessage());
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    }
                );
            };


            $scope.sendVerificationEmail = function(entityEmailIdent) {

                var entityEmailVerifyPost;
                var postData = {
                    EntityEmailIdent: entityEmailIdent
                }
                entityEmailVerifyPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYEMAILVERIFY]), postData);

                return entityEmailVerifyPost.then(function(pl) {
                        $scope.newEmailAddress = undefined;
                        growl.success('The verification email has been sent!');
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    }
                );
            };


            $scope.deleteEntityEmail = function(entityEmailIdent, index) {

                var entityEmailDelete;
                entityEmailDelete = RESTService.delete(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYEMAIL]), entityEmailIdent);

                return entityEmailDelete.then(function(pl) {
                        $scope.EntityEmail.splice(index, 1);
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());
                    }
                );
            }; // deleteEntityEmail


            $scope.registerEntity = function(entityEmailIdent) {

                registrationService.sendRegistrationEmail($scope.Profile.Ident, entityEmailIdent).then(function(pl) {

                        growl.success('Great! We\'ve sent an email so that ' + $scope.Profile.FullName + ' can register and log into ZenPRM.');

                    },
                    function(errorPl) {

                        growl.error($global.GetRandomErrorMessage());

                    });

            }; //registerEntity


            /* -------------------------------- */
            /* ORGANIZATION HIERARCHY */
            /* -------------------------------- */


            $scope.setupEntityHierarchy = function() {

                if ($scope.IsCustomer()) {
                    var isPerson = $scope.Profile.Person;

                    $scope.HierarchyType = $filter('filter')(LookupTablesService.HierarchyType, { ToEntityIsPerson: isPerson }, true);

                    entityNetworkService.getEntityNetworkNonPersonResoures().then(function(data) {
                        $scope.networkOrgs = data;

                        // need to setup the tags to match the hierarchy structure
                        angular.forEach($scope.networkOrgs, function(value, key) {
                            value.EntityHierarchyIdent = value.EntityIdent;
                            value.Organization = value.DisplayName;
                        });

                        entityHierarchyService.getEntityHierarchyAsTags($scope.EntityIdent, true).then(function(data) {
                            $scope.hierarchyTags = data;
                        });
                    });
                };

            };

            $scope.loadHierarchyTags = function(query, datasource) {
                return $filter('filter')(datasource, query);
            };

            $scope.AddOrganization = function(organization, HierarchyTypeIdent) {

                var data = {
                    HierarchyTypeIdent: HierarchyTypeIdent,
                    FromEntityIdent: organization.EntityIdent,
                    ToEntityIdent: $scope.Profile.Ident
                };

                entityHierarchyService.addEntityHierarchy(data).then(function(data) {
                    growl.success($global.GetRandomSuccessMessage());
                    $scope.setupEntityHierarchy();
                });

            };

            $scope.RemoveOrganization = function(organization) {

                entityHierarchyService.deleteEntityHierarchy(organization.EntityHierarchyIdent).then(function(data) {
                    growl.success('This organization has been successfully removed.');
                    $scope.setupEntityHierarchy();
                });

            };


            /* -------------------------------- */
            /* HELPER FUNCTIONS */
            /* -------------------------------- */


            $scope.IsOrganization = function() {
                //WARNING!!! This doesn't actually check if it's and organization, rather that it's not a Provider
                return !$scope.IsProvider();
            }

            $scope.IsProvider = function() {
                return $scope.Person;
            }

            $scope.IsCustomer = function() {
                return $global.isCustomer();
            };

            $scope.IsMyProfile = function() {
                var bolValid = false;
                if ($global.BaseUserIdent == $scope.Profile.Ident || $global.UserIdent == $scope.Profile.Ident) {
                    bolValid = true;
                }
                return bolValid;
            };


            init();

        }
    ]);