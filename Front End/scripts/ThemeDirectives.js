'use strict'

angular
.module('theme.directives', [])
.directive('disableAnimation', ['$animate', function ($animate) {
    return {
        restrict: 'A',
        link: function ($scope, $element, $attrs) {
            $attrs.$observe('disableAnimation', function (value) {
                $animate.enabled(!value, $element);
            });
        }
    }
}])
.directive('slideOut', function () {
    return {
        restrict: 'A',
        scope: {
            show: '=slideOut'
        },
        link: function (scope, element, attr) {
            element.hide();
            scope.$watch('show', function (newVal, oldVal) {
                if (newVal !== oldVal) {
                    element.slideToggle({
                        complete: function () { scope.$apply(); }
                    });
                }
            });
        }
    }
})
.directive('slideOutNav', ['$timeout', function ($t) {
    return {
        restrict: 'A',
        scope: {
            show: '=slideOutNav'
        },
        link: function (scope, element, attr) {
            scope.$watch('show', function (newVal, oldVal) {
                if ($('body').hasClass('collapse-leftbar')) {
                    if (newVal == true)
                        element.css('display', 'block');
                    else
                        element.css('display', 'none');
                    return;
                }
                if (newVal == true) {
                    element.slideDown({
                        complete: function () {
                            $t(function () { scope.$apply() })
                        }
                    });
                } else if (newVal == false) {
                    element.slideUp({
                        complete: function () {
                            $t(function () { scope.$apply() })
                        }
                    });
                }
            });
        }
    }
}])
.directive('tileLarge', function () {
    return {
        restrict: 'E',
        scope: {
            item: '=data'
        },
        templateUrl: 'tile-large.html',
        replace: true,
        transclude: true
    }
})
.directive('tileMini', function () {
    return {
        restrict: 'E',
        scope: {
            item: '=data'
        },
        replace: true,
        templateUrl: 'tile-mini.html'
    }
})
.directive('tile', function () {
    return {
        restrict: 'E',
        scope: {
            heading: '@',
            type: '@'
        },
        transclude: true,
        templateUrl: 'tile-generic.html',
        link: function (scope, element, attr) {
            var heading = element.find('tile-heading');
            if (heading.length) {
                heading.appendTo(element.find('.tiles-heading'));
            }
        },
        replace: true
    }
})
// specific to app
.directive('stickyScroll', function () {
    return {
        restrict: 'A',
        link: function (scope, element, attr) {
            function stickyTop() {
                var topMax = parseInt(attr.stickyScroll);
                var headerHeight = $('header').height();
                if (headerHeight > topMax) topMax = headerHeight;
                if ($('body').hasClass('static-header') == false)
                    return element.css('top', topMax + 'px');
                var window_top = $(window).scrollTop();
                var div_top = element.offset().top;
                if (window_top < topMax) {
                    element.css('top', (topMax - window_top) + 'px');
                } else {
                    element.css('top', 0 + 'px');
                }
            }

            $(function () {
                $(window).scroll(stickyTop);
                stickyTop();
            });
        }
    }
})
.directive('rightbarRightPosition', function () {
    return {
        restrict: 'A',
        scope: {
            isFixedLayout: '=rightbarRightPosition'
        },
        link: function (scope, element, attr) {
            scope.$watch('isFixedLayout', function (newVal, oldVal) {
                if (newVal != oldVal) {
                    setTimeout(function () {
                        var $pc = $('#page-content');
                        var ending_right = ($(window).width() - ($pc.offset().left + $pc.outerWidth()));
                        if (ending_right < 0) ending_right = 0;
                        $('#page-rightbar').css('right', ending_right);
                    }, 100);
                }
            });
        }
    };
})
.directive('fitHeight', ['$window', '$timeout', '$location', function ($window, $timeout, $location) {
    return {
        restrict: 'A',
        scope: true,
        link: function (scope, element, attr) {
            scope.docHeight = $(document).height();
            var setHeight = function (newVal) {
                var diff = $('header').outerHeight();
                if ($('body').hasClass('layout-horizontal')) diff += 112;
                if ((newVal - diff) > element.outerHeight()) {
                    element.css('min-height', (newVal - diff) + 'px');
                } else {
                    element.css('min-height', $(window).height() - diff);
                }
            };
            scope.$watch('docHeight', function (newVal, oldVal) {
                setHeight(newVal);
            });
            $(window).on('resize', function () {
                setHeight($(document).height());
            });
            var resetHeight = function () {
                scope.docHeight = $(document).height();
                $timeout(resetHeight, 1000);
            }
            $timeout(resetHeight, 1000);
        }
    };
}])
.directive('backToTop', function () {
    return {
        restrict: 'AE',
        link: function (scope, element, attr) {
            element.click(function (e) {
                $('body').scrollTop(0);
            });
        }
    }
});

