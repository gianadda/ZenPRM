'use strict'

angular
    .module('App.Services', [])
    .service('$global', ['$rootScope', '$document', '$log', function($rootScope, $document, $log) {

        this.init = function() {

            $log.debug("Initizializing $global");
        };

        this.init();

        var counter = 0

        this.getCookieByName = function(cname) {
            var name = cname + "=";
            var ca = document.cookie.split(';');
            for (var i = 0; i < ca.length; i++) {
                var c = ca[i];
                while (c.charAt(0) == ' ') {
                    c = c.substring(1);
                }
                if (c.indexOf(name) == 0) {
                    return c.substring(name.length, c.length);
                }
            }
            return "";
        };

        this.GetRandomSuccessMessage = function() {

            var messageText = '';
            //Random number between 1-10
            switch (Math.floor((Math.random() * 10) + 1)) {
                case 1:
                    messageText = "Success!";
                    break;
                case 2:
                    messageText = "Ca-ching!";
                    break;
                case 3:
                    messageText = "Now that was a value-based save!";
                    break;
                case 4:
                    messageText = "Got it. Remember when you used to do this in a spreadsheet?";
                    break;
                case 5:
                    messageText = "That is some serious productivity gain!";
                    break;
                case 6:
                    messageText = "Victory!";
                    break;
                case 7:
                    messageText = "Holy Moly Guacamole! You are really getting a lot done!";
                    break;
                case 8:
                    messageText = "Everything is going so well, you’ll be able to get back to other tasks way sooner!";
                    break;
                case 9:
                    messageText = "You are really crushing it today!";
                    break;
                case 10:
                    counter += 1;
                    if (counter > 3) {

                        messageText = "You have done so well... <br> I think you deserve a UNICORN! <img width='100' src='/assets/img/unicorn.png'/>";
                        counter = 0;
                    } else {

                        messageText = "Great Job!";
                    }
                    break;
            }
            return messageText;

        }



        this.GetRandomErrorMessage = function() {

            var messageText = '';

            switch (Math.floor((Math.random() * 10) + 1)) {
                case 1:
                    messageText = "Oh No! It looks like there was a problem.";
                    break;
                case 2:
                    messageText = "Oh No! It looks like there was a problem.";
                    break;
                case 3:
                    messageText = "Oh No! It looks like there was a problem.";
                    break;
                case 4:
                    messageText = "Oh No! It looks like there was a problem.";
                    break;
                case 5:
                    messageText = "Oh No! It looks like there was a problem.";
                    break;
                case 6:
                    messageText = "Oh No! It looks like there was a problem.";
                    break;
                case 7:
                    messageText = "Oh No! It looks like there was a problem.";
                    break;
                case 8:
                    messageText = "Oh No! It looks like there was a problem.";
                    break;
                case 9:
                    messageText = "Oh No! It looks like there was a problem.";
                    break;
                case 10:
                    messageText = "Oh No! It looks like there was a problem.";

            }
            return messageText;

        }

        this.settings = {
            isSystemAdmin: false,
            isLoggedIn: false,
            fullName: '',
            alerts: [],
            notifications: [],
            messages: []
        };

        this.RESTControllerNames = {

            // please keep alphabetical!@intToEntityIdent
            ADDENTITYTONETWORK: 'Entity/AddEntityToNetwork',
            ADDENTITYTONETWORKBYNPI: 'Entity/AddEntityToNetworkByNPI',
            ADDENTITYTONETWORKBYCSV: 'Entity/AddEntityToNetworkByCSV',
            ASUSER: 'asuser',
            ASUSERACTIVITY: 'Entity/GetTopASUserActivity',
            AUDITHISTORY: 'Entity/GetAuditHistory',
            CHANGE: 'change',
            CHANGEPASS: 'changepassword',
            COMMUNITYNETWORKMAP: 'Entity/CommunityNetworkMap',
            ENTITY: 'entity',
            ENTITYNPI: 'entity/saveNPI',
            ENTITYCONNECTION: 'EntityConnection',
            ENTITYDEGREE: 'entitydegree',
            ENTITYDELEGATE: 'EntityDelegate',
            ENTITYEMAIL: 'entityemail',
            ENTITYEMAILVERIFY: 'entityemail/verify',
            ENTITYHIERARCHY: 'EntityHierarchy',
            ENTITYIMPORT: 'Entity/Import',
            ENTITYIMPORTVERIFY: 'Entity/Import/Verify',
            ENTITYINTERACTION: 'EntityInteraction',
            ENTITYLANGUAGE: 'entitylanguage',
            ENTITYLICENSE: 'EntityLicense',
            ENTITYMEASURES: 'EntityMeasures',
            ENTITYNETWORK: 'Entity/Network',
            ENTITYOTHERID: 'EntityOtherID',
            ENTITYPAYOR: 'entitypayor',
            ENTITYPROJECT: 'EntityProject',
            ENTITYPROJECTADDENTITYTOPROJECT: 'EntityProject/AddEntityToProject',
            ENTITYPROJECTREMOVEENTITYFROMPROJECT: 'EntityProject/RemoveEntityFromProject',
            ENTITYPROJECTARCHIVE: 'EntityProject/Archive',
            ENTITYPROJECTDETAILS: 'EntityProject/Details',
            ENTITYPROJECTEXPORT: 'EntityProject/export',
            ENTITYPROJECTREACTIVATE: 'EntityProject/Reactivate',
            ENTITYPROJECTREQUIREMENT: 'EntityProjectRequirement',
            ENTITYREPORT: 'EntityReport',
            ENTITYSEARCH: 'entitysearch',
            ENTITYSERVICES: 'entityservices',
            ENTITYSPECIALITY: 'entityspeciality',
            ENTITYSYSTEM: 'entitysystem',
            ENTITYTAXONOMY: 'entitytaxonomy',
            ENTITYTODO: 'entitytodo',
            FILES: 'files',
            FORGOTPASS: 'forgotpassword',
            IMPORTCOLUMNS: 'Lookup/ImportColumns',
            LOGIN: 'login',
            LOGINDELEGATE: 'login/delegate',
            LOGINEXTERNAL: 'login/external',
            LOGINGETCSP: 'login/getcsp',
            LOGINGETUSERIDENT: 'login/GetUserIdent',
            LOOKUPTABLES: 'Lookup/GetLookupTables',
            MUSTCHANGEPASS: 'mustchangepassword',
            NAVIGATION: 'navigation',
            NPPESLOOKUP: 'NPPESLookup',
            ORGANIZATIONS: 'organizations',
            REFERRALS: 'referrals',
            REGISTER: 'register',
            REQUIREMENTTYPE: 'requirementtype',
            SYSROLE: 'systemrole',
            REMOVEENTITYFROMNETWORK: 'Entity/RemoveEntityFromNetwork',
            SEARCHENTITY: 'Entity/SearchEntity',
            SEARCHENTITYFORASSIGN: 'Entity/SearchEntityForAssignment',
            SEARCHENTITYFORCONNECTION: 'Entity/SearchEntityForConnection',
            USERNAMEUNIQUE: 'checkunique',
            VERIFYOPENPROJECTLINK: 'VerifyOpenProjectlink',
            WATSONTONEANALYZER: 'open-data/WatsonToneAnalyzer',
            WATSONTONEANALYZERBYIDENT: 'open-data/WatsonToneAnalyzerByIdent',
            ZENOPENDATA: 'open-data'

        };

        this.get = function(key) {
            return this.settings[key];
        };

        this.set = function(key, value) {
            this.settings[key] = value;
        };

        this.values = function() {
            return this.settings;
        };

    }]) //end service
    .service('ZenValidation', ['$http', '$location', '$log', function($http, $location, $log) {

        this.ValidNPI = function(npi) {
            //http://jsfiddle.net/alexdresko/cLNB6/
            var tmp;
            var sum;
            var i = 0;
            var j;

            if (npi) { i = npi.length; };

            if ((i == 15) && (npi.indexOf("80840", 0, 5) == 0))
                sum = 0;
            else if (i == 10)
                sum = 24;
            else
                return false;
            j = 0;
            while (i != 0) {
                tmp = npi.charCodeAt(i - 1) - '0'.charCodeAt(0);
                if ((j++ % 2) != 0) {
                    if ((tmp <<= 1) > 9) {
                        tmp -= 10;
                        tmp++;
                    }
                }
                sum += tmp;
                i--;
            }
            if ((sum % 10) == 0)
                return true;
            else
                return false;
        };

        this.ValidDEANumber = function(value) {
            if (/^\S{2}\d{7}$/i.test(value)) {
                return true;
            }
            if (angular.isDefined(value)) {
                if (value.trim().length == 0) {
                    return true;
                }
            }
            return false;
        };

        this.ValidImageURL = function(value) {
            var s = value;
            //remove the querystring prior to testing the image url.
            if (value) {
                if (value.indexOf('?') > 0) {
                    s = value.substring(0, value.indexOf('?'));
                }
            }
            if (/^(http(s?)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(?:\/\S*)?(?:[a-zA-Z0-9_])+\.(?:jpg|jpeg|gif|png))$/i.test(s)) {
                return true;
            }
            if (angular.isDefined(value)) {
                if (value.trim().length == 0) {
                    return true;
                }
            }
            return false;
        };

        this.ValidTaxIDNumber = function(value) {
            if (/^([07][1-7]|1[0-6]|2[0-7]|[35][0-9]|[468][0-8]|9[0-589])-?\d{7}$/i.test(value)) {
                return true;
            }
            if (angular.isDefined(value)) {
                if (value.trim().length == 0) {
                    return true;
                }
            }
            return false;
        };
        this.ValidMedicareUPIN = function(value) {
            if (angular.isDefined(value)) {
                if (value.trim().length == 0 || value.trim().length == 6) {
                    return true;
                }
            }
            return false;
        };

        this.ValidAlpha = function(value) {
            if (/^[a-z _-]+$/i.test(value)) {
                return true;
            }
            if (angular.isDefined(value)) {
                if (value.trim().length == 0) {
                    return true;
                }
            }
            return false;
        };

        this.ValidURL = function(value) {
            if (/^(http|https|ftp)?(:\/\/)([a-z0-9-]+).?[a-z0-9-]+(.|:)([a-z0-9-]+)+([\/?].*)?$/i.test(value)) {
                return true;
            }
            if (angular.isDefined(value)) {
                if (value.trim().length == 0) {
                    return true;
                }
            }
            return false;
        };

        this.ValidPhoneNumber = function(value) {
            if (/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.test(value)) {
                return true;
            }
            if (angular.isDefined(value)) {
                if (value.trim().length == 0) {
                    return true;
                }
            }
            return false;

        };

        this.ValidAlphaNumericSymbols = function(value) {

            if (/^[a-z0-9.,#$%^&*;: \-]+$/i.test(value)) {
                return true;
            }
            if (angular.isDefined(value)) {
                if (value.trim().length == 0) {
                    return true;
                }
            }
            return false;

        };

        this.ValidNumericSymbols = function(value) {

            if (/^[0-9.,$%^&*;: \-]+$/i.test(value)) {
                return true;
            }
            if (angular.isDefined(value)) {
                if (value.trim().length == 0) {
                    return true;
                }
            }
            return false;

        };

        this.ValidAlphaNumeric = function(value) {
            if (/^[a-z0-9 _-]+$/i.test(value)) {
                return true;
            }
            if (angular.isDefined(value)) {
                if (value.trim().length == 0) {
                    return true;
                }
            }
            return false;
        };


    }]) //end service
    .service('RESTService', ['$http', '$location', '$log', function($http, $location, $log) {

        //All of these should handle null or empty string values and log the errors
        //**Note that for every url that includes a '/' + ident request,
        //the name of the corresponding web api controller MUST be ident to match them

        this.protocol = 'http://'
        this.domain = 'localhost:50972';
        this.apiVersion = 'api';

        if ($location.$$port != 1337) {

            this.protocol = $location.$$protocol + '://';
            this.domain = $location.$$host;
            this.apiVersion = 'api';

        }

        //Returns a concatenated path based on an array of variables.
        //eg. RESTService.getControllerPath([$global.RESTControllerNames.SWMASTER, $global.get('SWMasterID'),$global.RESTControllerNames.COMPANIES,$scope.company.SWCompanyID,$global.RESTControllerNames.ITEMCATEGORIES])
        //Returns a concatenated string: i.e. /swmaster/90/companies/1001/itemcategories
        this.getControllerPath = function(pathArray) {

            var path = this.protocol + this.domain + "/" + this.apiVersion;

            if (angular.isArray(pathArray)) {
                angular.forEach(pathArray, function(value, key) {
                    path += '/' + value;
                })
            } else {
                $log.debug("getControllerName param is not an array.");
            };

            $log.log("getControllerName: " + path);

            return path;
        }


        //Posts a new JSON Object
        //Returns: Result Object
        this.post = function(controllerName, postData) {
            var request = $http({
                withCredentials: true,
                method: 'post',
                url: controllerName,
                data: postData
            });
            return request;
        }

        this.postWithTimeout = function(controllerName, postData, timeout) {
            var request = $http({
                withCredentials: true,
                method: 'post',
                timeout: timeout,
                url: controllerName,
                data: postData
            });
            return request;
        }

        this.postAsChild = function(controllerName, ident, childControllerName, postData) {

            var url = '';
            url = controllerName + '/' + ident + '/' + childControllerName;

            var request = $http({
                withCredentials: true,
                method: 'post',
                url: url,
                data: postData
            });
            return request;
        }

        //Get an item or all items from an end-point
        //Returns: Result Object
        this.get = function(controllerName, ident) {
            var url = ""

            if (ident) {
                url = controllerName + '/' + ident;
            } else {
                url = controllerName;
            }

            var request = $http({
                withCredentials: true,
                method: 'get',
                url: url
            });

            return request;
        }

        //Get an item or all items from an end-point
        //Returns: Result Object
        this.getWithParams = function(controllerName, searchParams, ident) {

            if (ident) {

                var url = controllerName + '/' + ident + '?';

            } else {

                var url = controllerName + '?';

            };

            if (angular.isArray(searchParams)) {
                angular.forEach(searchParams, function(value, key) {
                    url += '&' + value.name + '=' + value.value;
                })
            };

            url = url.replace("?&", "?");

            var request = $http({
                withCredentials: true,
                method: 'get',
                url: url
            });

            return request;
        }

        //Get an item or all items from an end-point
        //Returns: Result Object
        this.getAsChild = function(controllerName, ident, childControllerName) {
            var url = '';
            url = controllerName + '/' + ident + '/' + childControllerName;

            var request = $http({
                withCredentials: true,
                method: 'get',
                url: url
            });

            return request;
        }

        //Update an item
        //Returns: Result Object
        this.put = function(controllerName, ident, putData) {

            var url = controllerName

            //if there's 3 params, use ident and put the data, else the second parameter *IS* the payload
            if (putData) {
                url = controllerName + '/' + ident;
            } else {
                putData = ident;
            }

            var request = $http({
                method: 'put',
                withCredentials: true,
                url: url,
                data: putData
            });
            return request;
        }

        //Delete an item
        //Returns: Result Object
        this.delete = function(controllerName, deleteIdent) {

            var url = controllerName

            if (deleteIdent) {
                url = controllerName + '/' + deleteIdent;
            } else {
                url = controllerName;
            }

            var request = $http({
                method: 'delete',
                withCredentials: true,
                url: url
            });

            return request;
        }


        //Delete an item
        //Returns: Result Object
        this.deleteIdentAsObject = function(controllerName, putData) {

            var url = controllerName

            url = controllerName;

            var request = $http({
                method: 'delete',
                withCredentials: true,
                url: url,
                data: putData,
                headers: {
                    "Content-Type": "application/json"
                }
            });

            return request;
        }


    }])




.service('MyProfileService', function($global, RESTService, $q, growl, identity) {

        var ProfileCache = [];

        this.getProfile = function(ident) {

            if (ident == null) {
                ident = identity.getUserIdent();
            }

            var entityGet;
            var CurrentLoad = {
                Ident: ident,
                Data: undefined,
                LastLoadDateTimeStamp: new Date().getTime(),
                TTL: 60000 //one minunte
            };

            //Turned off cache
            //ProfileCache = [];

            var LastLoad = undefined;
            angular.forEach(ProfileCache, function(value, key) {
                if (value.Ident == ident) {
                    LastLoad = value;
                    ProfileCache.splice(key, 1);
                }
            });

            if (LastLoad) {
                if (((new Date().getTime() - LastLoad.LastLoadDateTimeStamp)) < LastLoad.TTL && LastLoad.Data) {

                    LastLoad.LastLoadDateTimeStamp = new Date();
                    ProfileCache.push(LastLoad);

                    return $q.when(LastLoad.Data);
                }
            }

            if (ident) {
                entityGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY]), ident);
            } else {
                entityGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.ENTITY]));
            }

            return entityGet.then(function(pl) {
                    CurrentLoad.LastLoadDateTimeStamp = new Date();
                    CurrentLoad.Data = pl.data

                    ProfileCache.push(CurrentLoad);

                    return CurrentLoad.Data;

                },
                function(errorPl) {
                    return errorPl;
                });



        };

        this.getMyProfile = function() {



            return this.getProfile(null);

        };

        this.clearProfileCache = function() {

            ProfileCache = [];

        };

    })
    .factory('LookupTablesService', function($global, RESTService, growl, $q) {

        if (!$global.LookupTables) {

            $global.LookupTables = {
                Loaded: false,
                PCMHStatus: [],
                Taxonomy: [],
                Services: [],
                Payor: [],
                Language: [],
                MeaningfulUse: [],
                Gender: [],
                Speciality: [],
                States: [],
                Degree: [],
                EntityType: [],
                ConnectionType: [],
                InteractionType: [],
                SystemType: [],
                ToDoType: [],
                EntitySearchDataType: [],
                EntitySearchFilterType: [],
                EntitySearchOperator: [],
                ActivityTypeGroup: [],
                MeasureType: [],
                HierarchyType: [],
                ToDoInitiatorType: [],
                ToDoStatus: [],
                MeasureLocation: []
            };

            var lookupTablesGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.LOOKUPTABLES]));

            lookupTablesGet.then(function(pl) {

                $global.LookupTables.PCMHStatus = pl.data.PCMHStatus;
                $global.LookupTables.Taxonomy = pl.data.Taxonomy;
                $global.LookupTables.Services = pl.data.Services;
                $global.LookupTables.Payor = pl.data.Payor;
                $global.LookupTables.Language = pl.data.Language;
                $global.LookupTables.MeaningfulUse = pl.data.MeaningfulUse;
                $global.LookupTables.Gender = pl.data.Gender;
                $global.LookupTables.Speciality = pl.data.Speciality;
                $global.LookupTables.States = pl.data.States;
                $global.LookupTables.Degree = pl.data.Degree;
                $global.LookupTables.EntityType = pl.data.EntityType;
                $global.LookupTables.ConnectionType = pl.data.ConnectionType;
                $global.LookupTables.InteractionType = pl.data.InteractionType;
                $global.LookupTables.SystemType = pl.data.SystemType;
                $global.LookupTables.ToDoType = pl.data.ToDoType;
                $global.LookupTables.EntitySearchDataType = pl.data.EntitySearchDataType;
                $global.LookupTables.EntitySearchFilterType = pl.data.EntitySearchFilterType;
                $global.LookupTables.EntitySearchOperator = pl.data.EntitySearchOperator;
                $global.LookupTables.ActivityTypeGroup = pl.data.ActivityTypeGroup;
                $global.LookupTables.MeasureType = pl.data.MeasureType;
                $global.LookupTables.HierarchyType = pl.data.HierarchyType;
                $global.LookupTables.ToDoInitiatorType = pl.data.ToDoInitiatorType;
                $global.LookupTables.ToDoStatus = pl.data.ToDoStatus;
                $global.LookupTables.MeasureLocation = pl.data.MeasureLocation;

                $global.LookupTables.Loaded = true;

            });

        }


        return $global.LookupTables;
    })

.service('APIInterceptor', function(growl, $q, $location, $rootScope) {
    var service = this;

    service.request = function(config) {
        return config;
    };


    service.response = function(response) {

        // this process has been injected to ensure that the client is utilizing the API functionality from the correct file version
        if (response.headers('versionnumber')) {

            var versionNumber = "v" + response.headers('versionnumber');

            if (versionNumber == "%%GULP_INJECT_VERSION%%") {
                $rootScope.ZenVersion = versionNumber.substring(1,versionNumber.length);
                return response;
            } else {
                //no auto close
                growl.error('There has been a recent release of ZenPRM and you were working on an out-of-date version. You have been logged out to ensure you are working on the correct version. Please review the version number in the bottom right hand corner. It should be ' + versionNumber + '. If it is not, then please press CTRL + F5 to refresh.', { ttl: -1 });
                //$location.reload;
                //$location.path('/login');
                //return $q.reject(response);
            };

        } else { // if we havent received the version # yet, skip this step
            return response;
        };

    };

    service.responseError = function(response) {

        //we need to check each API call. If it returns a 401, then return to login page (unless the 401 is from the login page)
        //12/30 - I tried injecting $state, but it caused a circular reference. This works with location, but should be followed up on so it is not a one-off
        if (response.status === 401 && $location.$$path !== '/login' && !$location.$$path.includes('/project-registration')) {

            // we return "False" when we reject an API call based on permissions
            if (response.data == 'False') {
                $location.path('/accessdenied');
            } else if ($location.$$path.includes('/oauth-redirect')) {
                $location.path('/login');
            } else {
                growl.error('Your session has timed out, please log back in to continue working.');
                $location.path('/login');
            };

            //$state.go('login');
        };

        // if we get a 404 back from the server, take them to the Not Found page
        if (response.status === 404 && $location.$$path !== '/404') {

            // we return "False" when we reject an API call based on permissions
            $location.path('/404');

        };

        // otherwise, return the rejected promise so that the responseError functionality is maintained
        return $q.reject(response);
    };
})

.service('UserAppService', function() { //used to pass an asUserIdent between controllers
        var UserIdent = null;
        var fullName = '';

        this.setUserIdent = function(value) {
            UserIdent = value;
        }

        this.getUserIdent = function() {
            $global.UserIdent = UserIdent;
            return UserIdent;
        }

        this.setFullName = function(value) {
            fullName = value;
        }

        this.getFullName = function() {
            return fullName;
        }

        this.clear = function() {
            UserIdent = null;
            fullName = '';
        }

        return {
            clear: this.clear,
            getUserIdent: this.getUserIdent,
            setUserIdent: this.setUserIdent,
            getFullName: this.getFullName,
            setFullName: this.setFullName
        };
    })
    .factory('templateCompiler', function($templateCache, $compile) {
        return {
            getCompiledHTML: function($scope, htmlTemplateName) {
                var tplCrop = $templateCache.get(htmlTemplateName);

                var template = angular.element(tplCrop);
                var linkFn = $compile(template);
                var compiledHTML = linkFn($scope);

                return compiledHTML;
            }
        }
    })
    .filter('safe_html', ['$sce', function($sce) {
        return function(val) {
            return $sce.trustAsHtml(val);
        };
    }])
    .directive('ngConfirmClick', [
        function() {
            return {
                priority: -1,
                restrict: 'A',
                link: function(scope, element, attrs) {
                    element.bind('click', function(e) {
                        var message = attrs.ngConfirmClick;
                        if (message && !confirm(message)) {
                            e.stopImmediatePropagation();
                            e.preventDefault();
                        }
                    });
                }
            }
        }
    ])

.config(['$httpProvider', function($httpProvider) {
    $httpProvider.interceptors.push('APIInterceptor');
}]);
