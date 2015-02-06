// Generated by CoffeeScript 1.8.0
(function() {
  var app, appData;

  appData = {
    name: "",
    id: "",
    banners: "",
    actors: [],
    data: {},
    artworkUrl: "",
    host: "http://tvserieswebapp.herokuapp.com",
    backgroundImageUrl: ""
  };

  if (Modernizr.localstorage) {
    appData.name = localStorage.getItem("series-name");
    appData.id = localStorage.getItem("series-id");
    appData.banners = JSON.parse(localStorage.getItem("series-banners"));
  } else if (Modernizr.sessionstorage) {
    appData.name = sessionStorage.getItem("series-name");
    appData.id = sessionStorage.getItem("series-id");
    appData.banners = JSON.parse(sessionStorage.getItem("series-banners"));
  }

  if (window.location.href.split('?')[1]) {
    appData.name = decodeURIComponent(((window.location.href.split('?')[1]).split("&")[0]).split('=')[1]);
    appData.id = decodeURIComponent(((window.location.href.split('?')[1]).split("&")[1]).split('=')[1]);
  }

  app = angular.module('app', []);

  app.controller('controller', [
    '$scope', '$http', function($scope, $http) {
      var series, url;
      this.appData = appData;
      this.appData.actorsNotDownloaded = true;
      this.appBehavior = {};
      series = this.appData;
      series.castAvailable = true;
      this.appBehavior.getCastAvailabilityCurrently = function() {
        return series.actors !== [0];
      };
      url = "" + series.host + "/series/seriesId/" + series.id + "/seriesOnly";
      $http.get(url).success(function(data) {
        return series.data = data;
      });
      if (!series.artworkUrl) {
        url = "" + series.host + "/series/seriesId/" + series.id + "/banners";
        $http.get(url).success(function(data) {
          var artworkFound, backgroundFound, banner, _i, _len, _ref;
          series.banners = data;
          artworkFound = false;
          backgroundFound = false;
          _ref = series.banners;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            banner = _ref[_i];
            if (artworkFound && backgroundFound) {
              break;
            }
            if (banner.type === "poster" && !artworkFound) {
              series.artworkUrl = banner.url;
              artworkFound = true;
            }
            if (banner.type === "fanart" && !backgroundFound) {
              series.backgroundImageUrl = banner.url;
              backgroundFound = true;
            }
          }
          $('#blur-layer').css("background", "#fafafa url(" + appData.artworkUrl + ") 0 0 / cover");
          return $('body').css("background", "#fafafa url(" + appData.artworkUrl + ") 0 0 / cover");
        });
      }
      if (series.actors.length === 0) {
        url = "" + series.host + "/series/seriesId/" + series.id + "/actors";
        $http.get(url).success(function(data) {
          series.actors = data;
          if (series.actors.length === 0) {
            appData.castAvailable = false;
          }
          return appData.actorsNotDownloaded = false;
        });
        return $scope.globalClick = false;
      }
    }
  ]);

  app.directive('episodeDirective', [
    '$timeout', function($timeout) {
      return function(scope, element, attrs) {
        return $timeout(function() {
          scope.$apply(function() {
            if (!scope.episode.name || scope.episode.name === "TBA") {
              scope.episode.name = "To Be Anounced";
            }
          });
          $(angular.element(element)).click(function() {
            var episodeBody;
            $('.episode-title').not($(this)).removeClass('selected');
            $(this).toggleClass('selected');
            $('.episode-title').not($(this)).parent().find('.episode-body').addClass('display-none');
            episodeBody = $(this).parent().find('.episode-body');
            episodeBody.toggleClass('display-none');
            if (navigator.platform !== "MacIntel" && !episodeBody.hasClass('nice-scrolled' && !episodeBody.hasClass('display-none'))) {
              console.log(navigator.platform === "MacIntel");
              episodeBody.niceScroll();
              episodeBody.addClass('nice-scrolled');
            }
          });
        });
      };
    }
  ]);

  app.directive('actorTemplate', function() {
    return {
      restrict: 'E',
      templateUrl: 'templates/actor-template.html'
    };
  });

  app.directive('seasonDirective', function() {
    return function(scope, element, attrs) {
      var episodesCount, seasonNumber;
      seasonNumber = scope.$index;
      episodesCount = +appData.data.seasons[seasonNumber].episodes.length;
      if (episodesCount % 2 === 0) {
        episodesCount /= 2;
      } else {
        episodesCount = episodesCount / 2 + 1;
      }
    };
  });

  app.filter('sliceFirstHalf', function() {
    return function(arr) {
      var end;
      if (arr.length % 2 === 1) {
        end = (arr.length + 1) / 2;
      } else {
        end = arr.length / 2;
      }
      return (arr || []).slice(0, end);
    };
  });

  app.filter('sliceSecondHalf', function() {
    return function(arr) {
      var start;
      if (arr.length % 2 === 0) {
        start = arr.length / 2;
      } else {
        start = (arr.length + 1) / 2;
      }
      return (arr || []).slice(start, arr.length);
    };
  });

  app.directive('blurLayerDirective', function() {
    return function(scope, element, attrs) {};
  });

  app.directive('allSeasonsDirective', function() {
    return function(scope, element, attrs) {
      var height;
      height = +$('#series').css('height').split('px')[0] + +$('#seasons-container').css('height').split('px')[0];
      return $('#blur-layer').css("height", height);
    };
  });

  app.directive('seriesOverviewBodyDirective', [
    '$timeout', function($timeout) {
      return function(scope, element, attrs) {
        if (navigator.platform !== "MacIntel" && !$('#overview-body').hasClass('nice-scrolled')) {
          element.niceScroll();
          return element.addClass('nice-scrolled');
        }
      };
    }
  ]);

  app.directive('actorDescriptionDirective', function() {
    return {
      link: function(scope, element, attrs) {
        console.log("actor-description");
        if (navigator.platform !== "MacIntel" && !element.hasClass('nice-scrolled')) {
          element.niceScroll();
          element.addClass('nice-scrolled');
        }
      }
    };
  });

  app.directive('allActorsDirective', [
    '$timeout', function($timeout) {
      return {
        link: function(scope, element, attrs) {
          $timeout(function() {
            return console.log(" cast " + appData.actors);
          });
          if (appData.actors.length === 0) {
            console.log("no cast details");
          }
        }
      };
    }
  ]);

  $('window').ready(function() {
    var height, width;
    if (navigator.platform !== "MacIntel") {
      $("html").niceScroll();
    }
    height = screen.height;
    width = screen.width;
    return $('body').css("font-size", "" + (15 / 1280 * width) + "px");
  });

}).call(this);


//# sourceMappingURL=app.js.map