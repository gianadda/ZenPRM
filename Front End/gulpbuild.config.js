/**
 * This file/module contains all configuration for the build process.
 *
 *    -- WHAT TO DO WHEN INSTALLING A NEW LIBRARY VIA BOWER: --
 *
 * Many of the objects/attributes below are self explanatory, but let's
 * run through what to do when you install a new library via bower for
 * your app.
 *
 * 1. Use `$ bower install <package> --save` to make sure your library
 *    is added to the bower.json file. This is necessary in production
 *    builds to maintain the proper package version when we switch
 *    our <script> and <link> tags to CDN sources.
 * 2. If the needed bower package is a JavaScript file, add the filepath
 *    of your JS file to the `bowerFiles.js` attribute's array. If it's CSS,
 *    add it to the `bowerFiles.css` array. Any fonts or assets can also
 *    be added to their respective attributes. These will be injected into
 *    the `index.html` of our dev build.
 * 3. If you'd like the switch out the local <script> and <head> tags of
 *    your bower packages with CDN sources in the minified (production)
 *    build, add an object to the array within the `bowerFiles.cdn` object.
 *    The `file:` attribute should match the local path from step 2, the
 *    `package:` attribute should match the name of the bower package
 *    (i.e. if you do $ bower install angular-ui-router, the package name
 *    is "angular-ui-router"). The `cdn:` attribute should be the URL to the
 *    CDN source you wish to use. Once this is done, you're good to go!
 */
var pkg = require('./package.json');

module.exports = {
    /**
     * The `build_dir` folder is where our projects are compiled during
     * development and the `compile_dir` folder is where our app resides once it's
     * completely built.
     */
    buildDir: 'build',
    prodDir: 'dist',

    /**
     * This is a collection of file patterns that refer to our app code (the
     * stuff in `src/`). These file paths are used in the configuration of
     * build tasks. `js` is all project javascript, less tests. `ctml` contains
     * any reusable components' (`common`) HTML files, while
     * `ahtml` contains the same, but for our app's code. `html` is just our
     * main index HTML file, `less` is our main LESS stylesheet, and `unit` contains our
     * app's unit tests. CSS contains any css files present, but we should be using
     * LESS for all of our stylesheets.
     */
    appFiles: {
        js: ['app/**/*.js', '!app/**/*.spec.js', '!scripts/**/*.spec.js', '!assets/**/*.js'],
        jsunit: ['app/**/*.spec.js'],
        scripts: ['scripts/*.js', 'scripts/**/*.js'],

        ahtml: ['app/**/*.html'],
        chtml: [],

        html: ['index.html'],

        scss: 'assets/scss/**/*.scss',
        less: 'assets/less/**/.scss',
        css: 'assets/css/**/*.css',
        assets: [
            'assets/img/**/*',
            'assets/files/*',
            'assets/fonts/*',
            'assets/templates/*',
            'bower_components/tinymce-dist/plugins/emoticons/img/*.gif',
            'bower_components/tinymce-dist/skins/lightgray/content.min.css'
        ]
    },

    /**
     * This is a collection of files used during testing only.
     */

    testFiles: {
        js: [
            'vendor/angular-mocks/angular-mocks.js'
        ]
    },

    miscFiles: {
        img: [
            'assets/img/favicon.png'
        ]
    },

    /**
     * This is the same as `appFiles`, except it contains patterns that
     * reference vendor code (`bower_components/`) that we need to place into the build
     * process somewhere. While the `app_files` property ensures all
     * standardized files are collected for compilation, it is the user's job
     * to ensure non-standardized (i.e. vendor-related) files are handled
     * appropriately in `bowerFiles.js`.
     *
     * The `bowerFiles.js` property holds files to be automatically
     * concatenated and minified with our project source files.
     *
     * The `bowerFiles.css` property holds any CSS files to be automatically
     * included in our app.
     *
     * The `bowerFiles.assets` property holds any assets to be copied along
     * with our app's assets. This structure is flattened, so it is not
     * recommended that you use wildcards.
     */
    //angular-xeditable
    bowerFiles: {
        jsCdn: [
            'bower_components/angular/angular.js',
            'bower_components/angular-ui-router/release/angular-ui-router.js',
            'bower_components/angular-ui-bootstrap-bower/ui-bootstrap.js',
            'bower_components/angular-ui-bootstrap-bower/ui-bootstrap-tpls.js',
            'bower_components/moment/min/moment.min.js',
            'bower_components/ng-table/dist/ng-table.js',
            'bower_components/d3/d3.js',
            'bower_components/papaparse/papaparse.min.js',
            'bower_components/textAngular/dist/textAngular-rangy.min.js',
            'bower_components/textAngular/dist/textAngular-sanitize.min.js',
            'bower_components/textAngular/dist/textAngular.min.js'
        ],
        cssCdn: [
            'bower_components/fontawesome/css/font-awesome.min.css',
            'bower_components/ng-table/dist/ng-table.css'
        ],
        jsLocal: [
            'node_modules/knwl.js/dist/knwl.min.js',
            'bower_components/angular-growl-v2/build/angular-growl.min.js',
            'bower_components/angular-filter/dist/angular-filter.min.js',
            'bower_components/ng-tags-input/ng-tags-input.min.js',
            'bower_components/angular-toggle-switch/angular-toggle-switch.min.js',
            'bower_components/angular-spinners/dist/angular-spinners.min.js',
            'bower_components/angular-xeditable/dist/js/xeditable.js',
            'bower_components/angular-ui-mask/dist/mask.min.js',
            'bower_components/Chart.js/Chart.min.js',
            'bower_components/angular-chart.js/dist/angular-chart.min.js',
            'bower_components/fastclick/lib/fastclick.js',
            'bower_components/angular-ui-validate/dist/validate.min.js',
            'bower_components/ng-sortable/dist/ng-sortable.min.js',
            'bower_components/ngstorage/ngStorage.min.js',
            'bower_components/nvd3/nv.d3.min.js',
            'bower_components/angularjs-nvd3-directives/dist/angularjs-nvd3-directives.min.js',
            'bower_components/leaflet/dist/leaflet.js',
            'bower_components/PruneCluster/dist/PruneCluster.min.js',
            'bower_components/file-saver/FileSaver.min.js',
            'bower_components/mousetrap/mousetrap.min.js',
            'bower_components/ng-img-crop/compile/minified/ng-img-crop.js',
            'bower_components/angular-clipboard/angular-clipboard.js',
            'bower_components/tinymce-dist/tinymce.js',
            'bower_components/tinymce-dist/themes/modern/theme.js',
            'bower_components/tinymce-dist/plugins/code/plugin.js',
            'bower_components/angular-ui-tinymce/src/tinymce.js',
            'bower_components/tinymce-dist/plugins/advlist/plugin.js',
            'bower_components/tinymce-dist/plugins/autolink/plugin.js',
            'bower_components/tinymce-dist/plugins/lists/plugin.js',
            'bower_components/tinymce-dist/plugins/link/plugin.js',
            'bower_components/tinymce-dist/plugins/image/plugin.js',
            'bower_components/tinymce-dist/plugins/charmap/plugin.js',
            'bower_components/tinymce-dist/plugins/print/plugin.js',
            'bower_components/tinymce-dist/plugins/preview/plugin.js',
            'bower_components/tinymce-dist/plugins/hr/plugin.js',
            'bower_components/tinymce-dist/plugins/anchor/plugin.js',
            'bower_components/tinymce-dist/plugins/pagebreak/plugin.js',
            'bower_components/tinymce-dist/plugins/searchreplace/plugin.js',
            'bower_components/tinymce-dist/plugins/wordcount/plugin.js',
            'bower_components/tinymce-dist/plugins/visualblocks/plugin.js',
            'bower_components/tinymce-dist/plugins/visualchars/plugin.js ',
            'bower_components/tinymce-dist/plugins/fullscreen/plugin.js',
            'bower_components/tinymce-dist/plugins/insertdatetime/plugin.js',
            'bower_components/tinymce-dist/plugins/media/plugin.js',
            'bower_components/tinymce-dist/plugins/nonbreaking/plugin.js',
            'bower_components/tinymce-dist/plugins/save/plugin.js',
            'bower_components/tinymce-dist/plugins/table/plugin.js',
            'bower_components/tinymce-dist/plugins/contextmenu/plugin.js',
            'bower_components/tinymce-dist/plugins/directionality/plugin.js',
            'bower_components/tinymce-dist/plugins/emoticons/plugin.js',
            'bower_components/tinymce-dist/plugins/template/plugin.js',
            'bower_components/tinymce-dist/plugins/paste/plugin.js',
            'bower_components/tinymce-dist/plugins/textcolor/plugin.js',
            'bower_components/tinymce-dist/plugins/colorpicker/plugin.js',
            'bower_components/tinymce-dist/plugins/textpattern/plugin.js',
            'bower_components/tinymce-dist/plugins/imagetools/plugin.js'
        ],
        cssLocal: [
            'bower_components/angular-growl-v2/build/angular-growl.min.css',
            'bower_components/ng-tags-input/ng-tags-input.min.css',
            'bower_components/ng-tags-input/ng-tags-input.bootstrap.min.css',
            'bower_components/angular-toggle-switch/angular-toggle-switch.css',
            'bower_components/angular-toggle-switch/angular-toggle-switch-bootstrap.css',
            'bower_components/angular-xeditable/dist/css/xeditable.css',
            'bower_components/nvd3/nv.d3.min.css',
            'bower_components/angular-chart.js/dist/angular-chart.css',
            'bower_components/leaflet/dist/leaflet.css',
            'bower_components/PruneCluster/dist/LeafletStyleSheet.css',
            'bower_components/textAngular/dist/textAngular.css',
            'bower_components/ng-sortable/dist/ng-sortable.min.css',
            'bower_components/ng-img-crop/compile/minified/ng-img-crop.css',
            'bower_components/tinymce-dist/skins/lightgray/skin.min.css'
        ],
        assets: [],
        fonts: [
            'bower_components/tinymce-dist/skins/lightgray/fonts/*',
            'bower_components/fontawesome/fonts/*',
            'bower_components/bootstrap/dist/fonts/*'
        ],
        cdn: [{
            file: 'bower_components/angular/angular.js',
            package: 'angular',
            cdn: 'https://ajax.googleapis.com/ajax/libs/angularjs/${version}/angular.min.js'
        }, {
            file: 'bower_components/angular-ui-router/release/angular-ui-router.js',
            package: 'angular-ui-router',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/angular-ui-router/${version}/angular-ui-router.js'
        }, {
            file: 'bower_components/angular-ui-bootstrap-bower/ui-bootstrap.js',
            package: 'angular-ui-bootstrap-bower',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/${version}/ui-bootstrap.min.js'
        }, {
            file: 'bower_components/angular-ui-bootstrap-bower/ui-bootstrap-tpls.js',
            package: 'angular-ui-bootstrap-bower',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/${version}/ui-bootstrap-tpls.min.js'
        }, {
            file: 'bower_components/fontawesome/css/font-awesome.min.css',
            package: 'fontawesome',
            cdn: 'https://maxcdn.bootstrapcdn.com/font-awesome/${version}/css/font-awesome.min.css'
        }, {
            file: 'bower_components/moment/min/moment.min.js',
            package: 'moment',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.10.6/moment.min.js'
        }, {
            file: 'bower_components/ng-table/dist/ng-table.js',
            package: 'ng-table',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/ng-table/${version}/ng-table.min.js'
        }, {
            file: 'bower_components/d3/d3.js',
            package: 'd3',
            cdn: 'https://d3js.org/d3.v3.min.js'
        }, {
            file: 'bower_components/fontawesome/css/font-awesome.min.css',
            package: 'fontawesome',
            cdn: 'https://maxcdn.bootstrapcdn.com/font-awesome/${version}/css/font-awesome.min.css'
        }, {
            file: 'bower_components/ng-table/dist/ng-table.css',
            package: 'ng-table',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/ng-table/${version}/ng-table.css'
        }, {
            file: 'bower_components/papaparse/papaparse.min.js',
            package: 'papaparse',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/PapaParse/4.1.2/papaparse.min.js'
        }, {
            file: 'bower_components/textAngular/dist/textAngular-rangy.min.js',
            package: 'rangy',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/textAngular/1.5.0/textAngular-rangy.min.js'
        }, {
            file: 'bower_components/textAngular/dist/textAngular-sanitize.min.js',
            package: 'textAngular',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/textAngular/1.5.0/textAngular-sanitize.min.js'
        }, {
            file: 'bower_components/textAngular/dist/textAngular.min.js',
            package: 'textAngular',
            cdn: 'https://cdnjs.cloudflare.com/ajax/libs/textAngular/1.5.0/textAngular.min.js'
        }]
    }
};
