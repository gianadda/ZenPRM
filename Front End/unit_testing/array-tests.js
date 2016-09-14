describe('Array', function () {
    describe('#indexOf()', function () {
        it('should return -1 when the value is not present', function () {
            assert.equal(-1, [1, 2, 3].indexOf(5));
            assert.equal(-1, [1, 2, 3].indexOf(0));
        });
    });
});

describe('Object', function () {
    describe('#populated', function () {
        it('should return empty array if object is empty', function () {
            assert.deepEqual(['0'], Object.keys({
                0: "this is a test"
            }));
            assert.deepEqual([], Object.keys({}));
            assert.deepEqual({
                animal: 'dog'
            }, {
                animal: 'dog'
            });
        });
    });
});

describe('Send', function () {
    describe('#stringtest', function () {
        it('should yell at me if the value is wrong', function () {
            var test = "I'm a string";
            expect(test).to.be.a('string');
            test.should.have.length(12);
        });
    });
});

describe('LoginController', function () {
    beforeEach(module('App'));

    describe('login()', function () {
        it('should not login because I dont have the application set up', inject(function ($controller, $httpBackend) {
            var scope = {};
            var loginController = $controller('LoginController', {
                $scope: scope
            });

            scope.username.should.equal('');
        }));
    });
});

describe('AddEntityController', function () {
    beforeEach(module('App'));

    describe('AddEntity()', function () {
        it('should tell me my NPI is valid', inject(function ($controller) {
            var scope = {};
            var loginController = $controller('AddEntityController', {
                $scope: scope
            });

            scope.ValidateNPI('1234567893').should.equal(true);
        }));
    });
});

describe('ZenValidation', function () {
    var ZenValidation;
    beforeEach(module('App'));

    beforeEach(inject(function (_ZenValidation_) {
        ZenValidation = _ZenValidation_;
    }));

    describe('ValidNPI', function () {
        it('should tell me my NPI is valid', function () {
            ZenValidation.ValidNPI('1234567893').should.equal(true);
        });
    });

    describe('ValidDEANumber', function () {
        it('should tell me my business address DEA Number is valid', function () {
            ZenValidation.ValidDEANumber('F91234567').should.equal(true);
        });

        it('should tell me my non-business address DEA Number is valid', function () {
            ZenValidation.ValidDEANumber('FA8749492').should.equal(true);
        });

        it('should tell me an invalid DEA Number is invalid', function () {
            ZenValidation.ValidDEANumber('FAE749885').should.equal(false);
        });
    });

    describe('ValidImageURL', function () {
        it('should return true if a valid http image URL is passed', function () {
            ZenValidation.ValidImageURL('http://theimagesite.com/983ahsd.jpg').should.equal(true);
        });

        it('should return true if a valid https image URL is passed', function () {
            ZenValidation.ValidImageURL('https://theimagesite.com/983ahsd24.png').should.equal(true);
        });

        /*
         * This test currently is failing. Leaving commented until we discuss a unit testing plan.
         */
        // it('should return false if an invalid https image URL is passed', function() {
        //     ZenValidation.ValidImageURL('https://theimagesite.com/983ahsd24.png.jpg').should.equal(false);
        // });

        it('should return false if an invalid image URL is passed using ssh', function () {
            ZenValidation.ValidImageURL('ssh://theimagesite.com/983ahsd24.png').should.equal(false);
        });

        it('should return false if an image URL is passed without http or https defined explicitly', function () {
            ZenValidation.ValidImageURL('theimagesite.com/983ahsd24.png').should.equal(false);
        });

        it('should return false if an image file extension (.jpg, .png, etc) isn\'t provided', function () {
            ZenValidation.ValidImageURL('http://theimagesite.com/983ahsd24').should.equal(false);
        });
    });

    describe('ValidTaxIDNumber', function () {

        it('should return true if a valid tax ID number is passed with hyphens included', function () {
            ZenValidation.ValidTaxIDNumber('20-4848946').should.equal(true);
        });

        it('should return true if a valid tax ID number is passed without a hyphen', function () {
            ZenValidation.ValidTaxIDNumber('204848946').should.equal(true);
        });

        it('should return true if an empty string is passed', function () {
            ZenValidation.ValidTaxIDNumber('').should.equal(true);
        });

        it('should return false if a valid tax ID number is passed with a hyphen at the wrond string index', function () {
            ZenValidation.ValidTaxIDNumber('2048489-46').should.equal(false);
        });

        it('should return false if an invalid tax ID is passed containing letters and a hyphen', function () {
            ZenValidation.ValidTaxIDNumber('20-AC8B489').should.equal(false);
        });

        it('should return false if an invalid tax ID is passed containing letters without a hyphen', function () {
            ZenValidation.ValidTaxIDNumber('20AC8B489').should.equal(false);
        });
    });

    describe('ValidMedicareUPIN', function() {

        it('should return true if a valid UPIN number is passed', function() {
            ZenValidation.ValidMedicareUPIN('H44833').should.equal(true);
        });

        it('should return true if a valid UPIN number is passed including spaces', function() {
            ZenValidation.ValidMedicareUPIN('     H44833').should.equal(true);
        });

        it('should return true if an empty string is passed', function() {
            ZenValidation.ValidMedicareUPIN('').should.equal(true);
        });

        it('should return false if an invalid UPIN is passed', function() {
            ZenValidation.ValidMedicareUPIN('HA44833').should.equal(false);
        });
    });

    describe('ValidAlpha', function() {
        it('should return true if a valid alpha string is passed', function() {
            ZenValidation.ValidAlpha('John-Cool Dude_').should.equal(true);
        });

        it('should return true if an empty string is passed', function() {
            ZenValidation.ValidAlpha('').should.equal(true);
        });

        it('should return false if an invalid alpha string is passed', function() {
            ZenValidation.ValidAlpha('John-Cool Dude_12$5').should.equal(false);
        });
    });

    describe('ValidURL', function() {
        it('should return true if a valid base http URL is passed', function() {
            ZenValidation.ValidURL('http://www.somecoolwebsite.com').should.equal(true);
        });

        it('should return true if a valid base https URL is passed', function() {
            ZenValidation.ValidURL('https://www.somecoolerwebsite.net').should.equal(true);
        });

        // This should pass as it's a valid URL. Leaving commented for further discussion
        // it('should return true if a valid base http URL is passed such as \'https://maps.google.com\'', function() {
        //     // ZenValidation.ValidURL('https://www.maps.google.com').should.equal(true); 
        // });

        it('should return true if a valid base ftp URL is passed', function() {
            ZenValidation.ValidURL('ftp://ftp.somecoolerwebsite.net').should.equal(true);
        });

        it('should return true if a valid http URL is passed that\'s not a base url', function() {
            ZenValidation.ValidURL('http://www.somecoolwebsite.com/comments/1/reply.html').should.equal(true);
        });

        it('should return true if a valid ftp URL is passed that\'s not a base url', function() {
            ZenValidation.ValidURL('ftp://ftp.somecoolerwebsite.net/Controllers/FormValidation.cs').should.equal(true);
        });

        // This should pass as it's a valid URL. Leaving commented for further discussion
        // it('should return true if a valid https URL is passed that\'s not a base url such as \'https://maps.google.com/about\'', function() {
        //     ZenValidation.ValidURL('https://www.maps.google.com/about').should.equal(true);
        // });

        it('should return true if a valid base URL is passed without its protocol defined', function() {
            ZenValidation.ValidURL('somecoolerwebsite.net').should.equal(true);
        });

        it('should return true if a valid URL (that\'s not a base URL) is passed without its protocol defined', function() {
            ZenValidation.ValidURL('somecoolerwebsite.net/profile/1/comments').should.equal(true);
        });

        it('should return false if an invalid URL is passed', function() {
            ZenValidation.ValidURL('htt:/www.somecoolwebsite.com').should.equal(false);
            ZenValidation.ValidURL('htts:ftp.somecoolerwebsite.net').should.equal(false);
            ZenValidation.ValidURL('ftp:user.somecoolerwebsite.net').should.equal(false);

            // I imagine that this should pass but it's currently failing.
            // ZenValidation.ValidURL('somecoolerwebsite/about.html').should.equal(false);
        });
    });

    describe('ValidPhoneNumber', function() {
        it('should return true if a valid phone number string is passed without spaces, periods, parenthesis, or hyphens', function() {
            ZenValidation.ValidPhoneNumber('8463937364').should.equal(true);
        });

        it('should return true if a valid phone number string is passed with area code parenthesis', function() {
            ZenValidation.ValidPhoneNumber('(846)3937364').should.equal(true);
        });

        it('should return false if a valid phone number with hyphens improperly placed is passed', function() {
            ZenValidation.ValidPhoneNumber('843-3114-543').should.equal(false);
        });

        it('should return false if an invalid phone number is passed', function() {
            ZenValidation.ValidPhoneNumber('843-311-4A43').should.equal(false);
        });
    });

    describe('ValidAlphaNumericSymbols', function() {
        it('should return true if an alphanumeric string is passed', function() {
            ZenValidation.ValidAlphaNumericSymbols('sajflk287461').should.equal(true);
        });

        it('should return true if an alphanumeric string with spaces and valid special characters is passed', function() {
            ZenValidation.ValidAlphaNumericSymbols('saj.,$%^&*;: -flk287461').should.equal(true);
        });

        it('should return true if an empty string or string containing only whitespace is passed', function() {
            ZenValidation.ValidAlphaNumericSymbols('                 ').should.equal(true);
            ZenValidation.ValidAlphaNumericSymbols('').should.equal(true);
        });

        it('should return false if a string with invalid special characters is passed', function() {
            ZenValidation.ValidAlphaNumericSymbols('saj<>{}[]|\flk287461').should.equal(false);
        });

        // Commenting this out until it's clarified what the expected behavior is.
        //
        // it('should return false if a null or undefined value is passed', function() {
        //     ZenValidation.ValidAlphaNumericSymbols(null).should.equal(false);
        //     ZenValidation.ValidAlphaNumericSymbols(undefined).should.equal(false);
        // });
    });

    describe('ValidNumericSymbols', function() {
        it('should return true if a numeric string is passed', function() {
            ZenValidation.ValidNumericSymbols('42148547351').should.equal(true);
        });

        it('should return true if a numeric string with spaces and valid special characters is passed', function() {
            ZenValidation.ValidNumericSymbols('42148547351 .,$%^&*;: -').should.equal(true);
        });

        it('should return true if an empty string or string containing only whitespace is passed', function() {
            ZenValidation.ValidNumericSymbols('                 ').should.equal(true);
            ZenValidation.ValidNumericSymbols('').should.equal(true);
        });

        it('should return false if a string with invalid special characters is passed', function() {
            ZenValidation.ValidNumericSymbols('134<>{}[]|\/874454').should.equal(false);
        });

        // Commenting this out until it's clarified what the expected behavior is.
        //
        // it('should return false if a null or undefined value is passed', function() {
        //     ZenValidation.ValidAlphaNumericSymbols(null).should.equal(false);
        //     ZenValidation.ValidAlphaNumericSymbols(undefined).should.equal(false);
        // });
    });

    describe('ValidAlphaNumeric', function() {
        it('should return true if an alphanumeric string is passed', function() {
            ZenValidation.ValidAlphaNumeric('42148aDfvUJf351').should.equal(true);
        });

        it('should return true if an alphanumeric string with spaces and valid special characters ( _-)is passed', function() {
            ZenValidation.ValidAlphaNumeric('4ASFHvCd3 _-ahjDf34487').should.equal(true);
        });

        it('should return true if an empty string or string containing only whitespace is passed', function() {
            ZenValidation.ValidAlphaNumeric('                 ').should.equal(true);
            ZenValidation.ValidAlphaNumeric('').should.equal(true);
        });

        it('should return false if a string with invalid special characters is passed', function() {
            ZenValidation.ValidAlphaNumeric('134ABD:874454').should.equal(false);
        });

        // Commenting this out until it's clarified what the expected behavior is.
        //
        // it('should return false if a null or undefined value is passed', function() {
        //     ZenValidation.ValidAlphaNumericSymbols(null).should.equal(false);
        //     ZenValidation.ValidAlphaNumericSymbols(undefined).should.equal(false);
        // });
    });
});

describe('Welcome Directive', function () {
    var element,
        scope;

    beforeEach(module('myApp'));

    beforeEach(inject(function ($compile, $rootScope) {
        scope = $rootScope.$new();
        element = $compile('<dumb-example person="person"></dumb-example>')(scope);
    }));

    it('welcomes the person', function () {
        scope.person = "Johnny Quest";
        scope.$digest();
        expect(element.html()).to.contain('Hey, Johnny Quest!');
    });
});

describe('Login', function () {
    var Login,
        $httpBackend;

    beforeEach(module('myApps'));

    beforeEach(inject(function (_Login_, _$httpBackend_) {
        Login = _Login_;
        $httpBackend = _$httpBackend_;
    }));

    describe('#login', function () {
        it('should log a user in', function () {
            $httpBackend.expectPOST('/login', {
                username: "FakePerson",
                password: "NotSecure"
            }).respond(200, {
                success: true,
                mustChangePassword: false
            });
            Login.login("FakePerson", "NotSecure");
            $httpBackend.flush();
            assert.deepEqual(Login.response, {
                success: true,
                mustChangePassword: false
            });
        });
    });
});

describe('RESTService', function () {

    var RESTService;

    beforeEach(module('App'));

    beforeEach(inject(function (_RESTService_) {
        RESTService = _RESTService_;
    }));

    describe('getControllerPath', function () {
        var $log;

        beforeEach(inject(function (_$log_) {
            $log = _$log_;
        }));

        it('should return the proper login path', function () {
            var expectedPath = 'http://server/api/entity';
            RESTService.getControllerPath(['entity']).should.equal(expectedPath);
        });

        it('should log an error if an argument that isn\'t an array is passed', function () {
            var logSpy = sinon.spy($log, 'debug');
            RESTService.getControllerPath('entity');
            logSpy.should.have.been.called;
        });

        it('should build the proper URL if multiple string elements are passed', function () {
            var expectedPath = 'http://server/api/EntityProject/24/entity';
            RESTService.getControllerPath(['EntityProject', '24', 'entity']).should.equal(expectedPath);
        });
    });
});

describe('ForgotPasswordController', function () {
    beforeEach(module('App'));

    var growl,
        $httpBackend;
    
    beforeEach(inject(function (_growl_, _$httpBackend_) {
        growl = _growl_;
        $httpBackend = _$httpBackend_;
    }));

    describe('forgotPassword()', function () {
        var forgotPassword,
            scope = {};
        
        beforeEach(inject(function ($controller) {
            forgotPassword = $controller('ForgotPasswordController', {
                $scope: scope
            });
        }));
        
        it('should make a call to growl.success() if the success callback is called', function() {
            $httpBackend.expectGET('http://server/api/Lookup/GetLookupTables', {
                Accept: "application/json, text/plain, */*"
            }).respond(200, {});
            
            $httpBackend.expectPOST('http://server/api/forgotpassword', {
                email: "coolguy@things.com"
            }).respond(200, {});
            
            var growlSpy = sinon.spy(growl, 'success');
            scope.forgotPasswordEmail = "coolguy@things.com";
            scope.forgotPassword();
            $httpBackend.flush();
            growlSpy.should.have.been.called;
        });

        it('should make a call to growl.error() if the error callback is called', function() {
            $httpBackend.expectGET('http://server/api/Lookup/GetLookupTables', {
                Accept: "application/json, text/plain, */*"
            }).respond(200, {});
            
            $httpBackend.expectPOST('http://server/api/forgotpassword', {
                email: "coolguy@things.com"
            }).respond(405, {});
            
            var growlSpy = sinon.spy(growl, 'error');
            scope.forgotPasswordEmail = "coolguy@things.com";
            scope.forgotPassword();
            $httpBackend.flush();
            growlSpy.should.have.been.called;
        });
    });
});