// Karma configuration
// Generated on Mon Dec 14 2015 16:11:54 GMT-0500 (Eastern Standard Time)

module.exports = function (config) {
    config.set({
        // base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: '',

        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        frameworks: ['mocha', 'chai', 'sinon-chai'],

        // list of files / patterns to load in the browser
        files: [
            'bower_components/angular/angular.js',
            'bower_components/angular-mocks/angular-mocks.js',
            'bower_components/angular-ui-router/release/angular-ui-router.js',
            'bower_components/angular-ui-bootstrap-bower/ui-bootstrap.js',
            'bower_components/angular-ui-bootstrap-bower/ui-bootstrap-tpls.js',
            'bower_components/moment/min/moment.min.js',
            'bower_components/ng-table/dist/ng-table.js',
            'bower_components/d3/d3.js',
            'bower_components/angular-growl-v2/build/angular-growl.js',
            'bower_components/angular-filter/dist/angular-filter.min.js',
            'bower_components/ng-tags-input/ng-tags-input.min.js',
            'bower_components/angular-toggle-switch/angular-toggle-switch.min.js',
            'bower_components/angular-spinners/dist/angular-spinners.min.js',
            'bower_components/angular-xeditable/dist/js/xeditable.js',
            'bower_components/Chart.js/Chart.min.js',
            'bower_components/angular-chart.js/angular-chart.js',
            'bower_components/fastclick/lib/fastclick.js',
            'bower_components/angular-ui-validate/dist/validate.min.js',
            'bower_components/ng-sortable/dist/ng-sortable.min.js',
            'scripts/**/*.js',
            'app/**/*.js',
            'unit_testing/**/*.js'
        ],

        // list of files to exclude
        exclude: [
        ],


        // preprocess matching files before serving them to the browser
        // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
        preprocessors: { },


        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['progress'],


        // web server port
        port: 9876,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        browsers: [
            'PhantomJS'
            //'Chrome'
        ],

        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: false,

        // Concurrency level
        // how many browser should be started simultanous
        concurrency: Infinity
    });
};