/*
Authors: Sean Jackson, Alex Barganier, Grant Dever
Date: 6/24/15
*/

var gulp = require('gulp-help')(require('gulp'));
/* bytediff tells us the before&after size of minified files */
var bytediff = require('gulp-bytediff');
var browserSync = require('browser-sync');
var cdnizer = require("gulp-cdnizer");
var changed = require('gulp-changed');
var concat = require('gulp-concat');
/* csso minifies CSS */
var csso = require('gulp-csso');
var debug = require('gulp-debug');
var del = require('del');
var gutil = require('gulp-util');
var inject = require("gulp-inject");
var injectVersion = require('gulp-inject-version');
var jshint = require('gulp-jshint');
var karma = require('karma').Server;
var less = require('gulp-less');
var merge = require('merge-stream');
var minifyHtml = require("gulp-minify-html");
var ngAnnotate = require('gulp-ng-annotate');
var ngHtml2Js = require("gulp-ng-html2js");
/* If plumber is passed into a steam of files
 * it will allow the stream to continue even if 
 * one of the `pipe()`'d in tasks fail, and 
 * output the error to console. */
var plumber = require('gulp-plumber');
var rename = require('gulp-rename');
var runSequence = require('run-sequence');
var confirm = require('gulp-confirm');
var sass = require('gulp-sass');
var sourcemaps = require('gulp-sourcemaps');
var streamqueue = require('streamqueue');
var stylish = require('jshint-stylish');
var uglify = require("gulp-uglify");
var vinylPaths = require('vinyl-paths');
var watch = require('gulp-watch');
var wrap = require("gulp-wrap");


/* require package.json and our build configuration. */
var pkg = require('./package.json');
var config = require('./gulpbuild.config.js');


/* Here we list the naming convention for our minified JS/CSS files. */
var prodFileName = pkg.name + '-' + pkg.version;

var prodOutputFiles = {
    js: prodFileName + '.min.js',
    css: prodFileName + '.css'
};

/* These are filenames that refer to the files output by the build-vendor-js and
 * build-vendor-css tasks. They're referenced in the call to gulp.src() in build-prod-index
 */
var prodVendorFiles = {
    js: 'bower_components.min.js',
    css: 'bower_components.css'
};

/* This task will compile any less/scss into css, and then concatenate the result with
 * any existing .css and then output it to the build directory
 */
gulp.task('style', 'compiles less, scss, and css into a single file', function() {

    /* The order of the 2nd-4th arguments passed into 'streamqueue' below determine the order
     * in which everything is concatenated together. Feel free to change the order
     * if you're having issues with certain styles overriding others. (First argument
     * comes first, last argument comes last).
     */
    return streamqueue({
                objectMode: true
            },
            gulp.src([].concat(config.appFiles.css)), // css
            gulp.src([].concat(config.appFiles.scss)).pipe(sass().on('error', sass.logError)), // scss
            gulp.src([].concat(config.appFiles.less)).pipe(less()) // less
        )
        .pipe(concat(pkg.name + '-' + pkg.version + '.css'))
        .pipe(gulp.dest(config.buildDir + '/assets/css/'));
});

/* Cleans our /build folder before we start our build.
 * The 'gulp.src([config.buildDir])' will source our files from the 'gulpbuild.config.js'
 * Applying the 'read:false' option prevents gulp from reading the contents of the file, 
 * making the task faster. 'del()' is the plugin that will delete the files.
 */
gulp.task('clean', 'cleans build dirs', function() {
    return gulp.src(config.buildDir)
        .pipe(vinylPaths(del));
});

/* Cleans our /dist folder that was built by 'prod' task
 * The 'gulp.src(config.prodDir)' will source our files from the 'gulpbuild.config.js'
 * Applying the 'read:false' option prevents gulp from reading the contents of the file, 
 * making the task faster. The 'confirm()' plugin allows gulp to read and write to the
 * command line. The question parameters will write to the command line
 * The input parameters is what gulp needs to see in order to continue with the task 
 * if user submits wrong parameter, the task will quit. The vinylPaths call allows us
 * to pass whatever is being passed through the `.pipe()` vinyl stream as an argument
 * to node packages that can't normally be piped into vinyl streams.
 */
gulp.task('clean:prod', 'cleans production build', function() {

    return gulp.src(config.prodDir, {
            read: false
        })
        .pipe(vinylPaths(del));
});

/*
 * Does the appropriate copying of our files into the proper
 * build directory. `changed()` helps us only copy the changed files.
 */
gulp.task('copy', 'copies all relevant files to their proper location in /build during development', function() {

    var assets = gulp.src([].concat(config.appFiles.assets), {
            base: 'assets/'
        })
        .pipe(changed(config.buildDir + '/assets'))
        .pipe(gulp.dest(config.buildDir + '/assets'));

    var appJS = gulp.src(config.appFiles.js)
        .pipe(changed(config.buildDir + '/app'))
        .pipe(wrap('(function(){\n"use strict";\n<%= contents %>\n})();'))
        .pipe(gulp.dest(config.buildDir + '/app'));

    var appScripts = gulp.src(config.appFiles.scripts)
        .pipe(injectVersion())
        .pipe(changed(config.buildDir + '/scripts'))
        .pipe(wrap('(function(){\n"use strict";\n<%= contents %>\n})();'))
        .pipe(gulp.dest(config.buildDir + '/scripts'));

    var vendorJS = gulp.src([].concat(config.bowerFiles.jsCdn, config.bowerFiles.jsLocal), {
            base: '.'
        })
        .pipe(changed(config.buildDir))
        .pipe(gulp.dest(config.buildDir));

    var vendorCSS = gulp.src([].concat(config.bowerFiles.cssCdn, config.bowerFiles.cssLocal), {
            base: '.'
        })
        .pipe(changed(config.buildDir))
        .pipe(gulp.dest(config.buildDir));

    var fonts = gulp.src(config.bowerFiles.fonts, {
            base: '.'
        })
        .pipe(changed(config.buildDir))
        .pipe(gulp.dest(config.buildDir));

    return merge([assets, fonts, appJS, vendorJS, vendorCSS]);

});

gulp.task('copy-html-dev', 'Copies in any additional HTML files needed, other than index.html', function() {

    var JavascriptDisabled = gulp.src('JavascriptDisabled.html').pipe(changed(config.buildDir)).pipe(gulp.dest(config.buildDir));

    return merge([JavascriptDisabled]);

});

gulp.task('copy-html-prod', 'Copies in any additional HTML files needed, other than index.html', function() {

    var JavascriptDisabled = gulp.src('JavascriptDisabled.html').pipe(changed(config.prodDir)).pipe(gulp.dest(config.prodDir));

    return merge([JavascriptDisabled]);

});


/*
 * Compiles our index.html and injects <script> and <link> tags for our bower
 * libraries. CSS will be injected between the <!-- inject:css --><!-- endinject -->
 * comments in our index.html, and JS will be injected between the 
 * <!-- inject:js --><!-- endinject --> comments. To add libraries for injection, refer
 * to the comments at the top of the gulpbuild.config.js file.
 */
gulp.task('index', 'injects script and css files into our index.html file', function() {
    var target = gulp.src('index.html');
    var files = [].concat(
        config.bowerFiles.jsCdn,
        config.bowerFiles.jsLocal,
        config.appFiles.js,
        config.appFiles.scripts,
        config.bowerFiles.cssLocal,
        config.bowerFiles.cssCdn,
        'assets/css/' + pkg.name + '-' + pkg.version + '.css',
        'templates-app.js',
        'templates-common.js',
        'assets/' + pkg.name + '-' + pkg.version + '.css'
    );
    var sources = gulp.src(files, {
        read: false,
        cwd: config.buildDir,
    });

    /* inject the files, and output to the build directory */
    return target
        .pipe(inject(sources, {
            addRootSlash: false
        }))
        .pipe(injectVersion())
        .pipe(gulp.dest(config.buildDir));
});

/*
 * Run test once and exit
 */
gulp.task('test', function(done) {
    new karma({
        configFile: __dirname + '/karma.conf.js',
        singleRun: true
    }, done).start();
});


/*
 * Once our code is copied into /build, go through and annotate it. This 
 * allows us to write our controller code lazily without having to wrap the entire 
 * second argument in an array. i.e. `.controller('myCtrl'. ['$scope'. function($scope){}]);`
 * can now be written as `.controller('myCtrl', function($scope){});`. ngAnnotate will 
 * add the array syntax for you when you build.
 */
gulp.task('ngAnnotate', 'runs ngAnnotate on our code for proper `strictdi` conformity', function() {
    return gulp.src(config.buildDir + '/app/**/*.js')
        .pipe(plumber())
        .pipe(ngAnnotate({
            add: true
        }))
        .pipe(gulp.dest(config.buildDir + '/app'));
});

/*
 * Compiles all of our application templates (*.html) into angular modules
 * within the file 'templates-app.js' and/or 'templates-common.js'. Angular will
 * then use $templateCache to serve up partial views. Be sure to include the 
 * `templates-app` and/or `templates-common` modules as dependencies in your 
 * main myApp module, and make sure your routes are in the format 
 * `ControllerDirectory/PartialView.html` without an `app/` or `src/` prefix.
 * These prefixes will make Angular fail when it tries to use $templateCache.
 * The filepaths in our routes should match those in `templates-app.js` or 
 * `templates-common.js`
 */
gulp.task('html2js', 'compiles .html files into javascript templates, injected into $templateCache', function() {
    var appTemplates = gulp.src(config.appFiles.ahtml)
        .pipe(plumber())
        .pipe(minifyHtml({
            empty: true,
            spare: true,
            quotes: true
        }))
        .pipe(ngHtml2Js({
            moduleName: 'templates-app'
        }))
        .pipe(concat('templates-app.js'))
        .pipe(uglify())
        .pipe(gulp.dest(config.buildDir));

    var commonTemplates = gulp.src(config.appFiles.chtml)
        .pipe(plumber())
        .pipe(minifyHtml({
            empty: true,
            spare: true,
            quotes: true
        }))
        .pipe(ngHtml2Js({
            moduleName: 'templates-common'
        }))
        .pipe(concat('templates-common.js'))
        .pipe(uglify())
        .pipe(gulp.dest(config.buildDir));

    return merge([appTemplates, commonTemplates]);
});

/*
 * Runs jsHint on all of our application javascript and runs
 * it through a pretty reporter that's displayed in console.
 */
gulp.task('jshint', 'runs jshint on our application code. reads a local copy of your .jshintrc in the root of the project', function() {
    /* We can't pass gulp.src multiple arrays, so we first concat
     * multiple arrays into a single array, then pass that to gulp.src */
    var files = config.appFiles.js.concat(config.appFiles.scripts);

    return gulp.src(files)
        .pipe(jshint())
        .pipe(jshint.reporter(stylish))
        .pipe(jshint.reporter('fail'));
});

/**
 * Creates a local webserver, watches all of our source files, and runs the appropriate tasks upon change
 * as well as reloads the browser for you. We use the runSequence in the callback function to make sure
 * all tasks that are kicked off run asynchronously in the right order.
 */
gulp.task('watch', function() {
    browserSync({
        port: 1337,
        server: {
            baseDir: "build"
        }
    });
    gulp.watch([config.appFiles.js, config.appFiles.scripts, config.appFiles.assets],
        function() {
            runSequence('copy', 'reload')
        }); // JSHint removed until standards are defined.
    gulp.watch([config.appFiles.ahtml, config.appFiles.chtml], function() {
        runSequence('html2js', 'reload');
    });
    gulp.watch(['index.html', './gulpbuild.config.js'], function() {
        runSequence('copy', 'index', 'reload')
    });
    gulp.watch(['assets/less/*.less', config.appFiles.css, config.appFiles.scss],
        function() {
            runSequence('style', 'reload');
        });
});

/* Reload tasks uses browserSync to refresh the browser when called by the watch task */
gulp.task('reload', 'reloads our browser when kicked off by the watch task', browserSync.reload);

/* -- PRODUCTION TASKS -- */

/*
 * This task minifies all of the JS files defined within the files var,
 * and minifies them, and outputs the .min file to the prod directory.
 * It also builds a sourcemap file to help with debugging using DevTools in
 * Chrome. Note: Only app-specific files should be included here, any bower
 * libraries should be handled externally via our `cdnify`
 */
gulp.task('build-prod-js', 'minifies all of our app JS for production', function() {

    // concat all of our app js files.
    var files = [].concat(config.appFiles.js, config.appFiles.scripts,
        config.buildDir + '/templates-app.js');
    console.log(files);
    return gulp.src(files)
        .pipe(sourcemaps.init())
        .pipe(plumber())
        .pipe(concat(prodOutputFiles.js, {
            newLine: ';'
        }))
        .pipe(ngAnnotate())
        .pipe(bytediff.start())
        .pipe(uglify())
        .pipe(bytediff.stop())
        .pipe(injectVersion())
        .pipe(sourcemaps.write('../maps'))
        .pipe(gulp.dest(config.prodDir + '/assets'));

});

/*
 * This task will take any vendor JS files without CDN sources, located in the 
 * config file within the config.bowerFiles.jsLocal attribute, compile them, and inject
 * the output file into the production build's index.html file. The logic of this is to
 * cut down on requests made to CDNs for libraries that have small filesizes, since it's 
 * more efficient in the end to contain them on our own server.
 */
gulp.task('build-vendor-js', 'concats and minifies all our non-cdn bower js into one', function() {
    return gulp.src(config.bowerFiles.jsLocal)
        .pipe(debug())
        .pipe(plumber())
        .pipe(concat(prodVendorFiles.js))
        .pipe(bytediff.start())
        .pipe(uglify({
            mangle: false
        }))
        .pipe(bytediff.stop())
        .pipe(gulp.dest(config.prodDir + '/assets'));
});

/*
 * This task minifies our CSS file from within our build directory and outputs it
 * to the production directory.
 */
gulp.task('build-prod-css', 'builds production ready CSS from /build', function() {
    var files = [].concat(config.buildDir + '/assets/css/*.css');
    console.log(files);
    return gulp.src(files)
        .pipe(plumber())
        .pipe(concat(prodOutputFiles.css))
        .pipe(bytediff.start())
        .pipe(csso())
        .pipe(bytediff.stop())
        .pipe(gulp.dest(config.prodDir + '/assets'));
});

/*
 * This task will take any vendor CSS files without CDN sources, located in the 
 * config file within the config.bowerFiles.cssLocal attribute, compile them, and inject
 * the output file into the production build's index.html file. The logic of this is to
 * cut down on requests made to CDNs for stylesheets that have small filesizes, since it's 
 * more efficient in the end to contain them on our own server.
 */
gulp.task('build-vendor-css', 'concats and minifies all our non-cdn bower css into one', function() {
    return gulp.src([].concat(config.bowerFiles.cssLocal))
        .pipe(debug())
        .pipe(plumber())
        .pipe(concat(prodVendorFiles.css))
        .pipe(bytediff.start())
        .pipe(csso())
        .pipe(bytediff.stop())
        .pipe(gulp.dest(config.prodDir + '/assets'))
});


/*
 * Here we inject all of our necessary <script> and <link> tags into our 
 * index.html, and output it to the prod directory. This includes our 
 * minified JS and CSS file, and any bower libraries noted in our 
 * gulpbuild.config.js file. To learn more about adding new bower libraries,
 * read the comments at the top of the gulpbuild.config.js file. Note that
 * all injected bower file tags will be converted to CDN sources in the next
 * `cdnify` task that's run.
 */
gulp.task('build-prod-index', 'builds our index.html file for production', function() {

    // copy over our templates
    var indexFile = gulp.src('index.html'); // t
    var files = [].concat(
        config.bowerFiles.jsCdn,
        config.bowerFiles.cssCdn,
        config.prodDir + '/assets/' + prodVendorFiles.js,
        config.prodDir + '/assets/' + prodVendorFiles.css,
        config.prodDir + '/assets/' + prodOutputFiles.css,
        config.prodDir + '/assets/' + prodOutputFiles.js
    );

    var sources = gulp.src(files);

    // inject the files, and copy it to the build directory
    return indexFile.pipe(inject(sources, {
            addRootSlash: false,
            ignorePath: 'dist/'
        }))
        .pipe(injectVersion())
        .pipe(gulp.dest(config.prodDir));


});

/* 
 * Here we pass in the index.html file output by the `build-prod-index` task,
 * and convert any bower file tags (local) to CDN sources for our prod build. The config 
 * for what gets converted is within the gulpbuild.config.js in the bowerFiles.cdn
 * attribute. To learn more about adding new bower libraries and setting up the
 * CDN conversion, check the comments at the top of the gulpbuild.config.js file.
 * To read the plug-in/API documentation, check out the repo for `gulp-cdnizer`.
 */
gulp.task('cdnify', 'changes our vendor sources in prod builds to point to cdn sources', function() {
    return gulp.src('dist/index.html')
        .pipe(cdnizer({
            allowRev: true,
            allowMin: true,
            files: config.bowerFiles.cdn
        }))
        .pipe(gulp.dest(config.prodDir));
});

/*
 * Here we copy over any potentially lingering files that we'll need for our production
 * build, i.e. a favicon or logo
 */
gulp.task('copy:prod', 'copies over anything necessary for our prod build, i.e. a favicon', function() {
    var assets = gulp.src(config.appFiles.assets, {
            base: 'assets/'
        })
        .pipe(plumber())
        .pipe(changed(config.prodDir + '/assets'))
        .pipe(gulp.dest(config.prodDir + '/assets'));

    return merge([assets]);
});

/**
 * Setup our default task's sequence, when `$ gulp` is run.
 */
gulp.task('default', 'runs -> build, watch', function() {
    runSequence('build', 'watch');
});

/*
 * Setup our build task's sequence, when `$ gulp build` is run.
 */
gulp.task('build', 'runs -> clean, style, html2js, copy, add-additional-html, ngAnnotate, index', function() {
    return runSequence('clean', 'style', 'html2js', 'copy', 'copy-html-dev', 'ngAnnotate', 'index');
});

/*
 * Setup our prod task's sequence, when `$ gulp build` is run.
 */
gulp.task('prod', 'builds our app for production, in /dist', function() {
    return runSequence('clean:prod', 'style', 'html2js', 'copy', 'ngAnnotate', 'index', 'copy-html-prod', 'build-prod-js',
        'build-vendor-js', 'build-prod-css', 'build-vendor-css', 'build-prod-index', 'cdnify', 'copy:prod');
});
