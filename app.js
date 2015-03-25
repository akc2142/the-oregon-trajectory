// jquery must be loaded before this...
require('angular');
require('fastclick');

var app = angular.module('the-oregon-trajectory',
    [
        require('ui.bootstrap'),
        require('ngTouch'),
        require('header-navbar'),
        require('splash-header'),
        require('app-footer'),
        require('main-menu'),
        require('shop'),
        require('you-win')
    ], function($httpProvider){
        FastClick.attach(document.body);
        delete $httpProvider.defaults.headers.common['X-Requested-With'];
    }
);

app.controller('MainCtrl', function($scope, $modal) {
    window.MainCtrl = this;  // for debug
    vm = this;
    vm.active_module = 'main-menu';
    //vm.submodules = [];  // secondary modules which are also active (NYI)

    vm.switchToModule = function(event, newModuleName){
        // enables switching between modules
        vm.active_module = newModuleName;

        // had to use jquery here... b/c I'm not angulicious enough
        $('.game-module').hide();
        $(newModuleName).show();
    }
    $scope.$on('switchToModule', vm.switchToModule);  // module switching via events
    vm.switchToModule({}, 'main-menu');  // init app by starting main menu

    vm.moduleIsActive = function(magicStr){
        // returns true if module identified by magicStr should be active currently
        if (magicStr === vm.active_module){
            return true
        } else {  // TODO: check for submodules
            return false
        }
    }

    // this example is retained here for later use
    /*
    $scope.showDownloadModal = function() {
        var modalInstance = $modal.open({
            templateUrl: 'downloadModal.html',
            controller: 'DownloadCtrl'
        });
    };
    */
});

/*
 * The following compatibility check is from:
 *
 * Bootstrap Customizer (http://getbootstrap.com/customize/)
 * Copyright 2011-2014 Twitter, Inc.
 *
 * Licensed under the Creative Commons Attribution 3.0 Unported License. For
 * details, see http://creativecommons.org/licenses/by/3.0/.
 */
var isOldBrowser;
(function () {

    var supportsFile = (window.File && window.FileReader && window.FileList && window.Blob);
    function failback() {
        isOldBrowser = true;
    }
    /**
     * Based on:
     *   Blob Feature Check v1.1.0
     *   https://github.com/ssorallen/blob-feature-check/
     *   License: Public domain (http://unlicense.org)
     */
    var url = window.webkitURL || window.URL; // Safari 6 uses "webkitURL".
    var svg = new Blob(
        ['<svg xmlns=\'http://www.w3.org/2000/svg\'></svg>'],
        { type: 'image/svg+xml;charset=utf-8' }
    );
    var objectUrl = url.createObjectURL(svg);

    if (/^blob:/.exec(objectUrl) === null || !supportsFile) {
        // `URL.createObjectURL` created a URL that started with something other
        // than "blob:", which means it has been polyfilled and is not supported by
        // this browser.
        failback();
    } else {
        angular.element('<img/>')
            .on('load', function () {
                isOldBrowser = false;
            })
            .on('error', failback)
            .attr('src', objectUrl);
    }

})();