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
    appData.artworkUrl = decodeURIComponent(((window.location.href.split('?')[1]).split("&")[2]).split('=')[1]);
    appData.altArtworkUrl = decodeURIComponent(((window.location.href.split('?')[1]).split("&")[3]).split('=')[1]);
    appData.currentArtworkUrl = appData.artworkUrl;
    if (window.innerWidth > 504 && window.innerWidth < 1101) {
      appData.currentArtworkUrl = appData.altArtworkUrl;
    }
  }

  app = angular.module('app', []);

  app.controller('controller', [
    '$scope', '$http', function($scope, $http) {
      var series, url;
      this.appData = appData;
      this.appData.actorsNotDownloaded = true;
      this.appBehavior = {};
      this.appData.seriesDataNotDownloaded = true;
      this.appData.seriesSubscriptionStatus = false;
      this.appData.seriesSubscriptionStatusDownloaded = false;
      series = this.appData;
      series.castAvailable = true;
      this.appBehavior.getCastAvailabilityCurrently = function() {
        return series.actors !== [0];
      };
      url = "/series/seriesId/" + series.id + "/seriesOnly";
      $http.get(url).success(function(data) {
        var episode, progressBar, season, _i, _j, _len, _len1, _ref, _ref1;
        series.data = data;
        series.seriesDataNotDownloaded = false;
        console.log("series data downloaded");
        series.data.comingUp = {};
        _ref = series.data.seasons;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          season = _ref[_i];
          _ref1 = season.episodes;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            episode = _ref1[_j];
            if ((new Date()).setHours(0, 0, 0, 0) <= (new Date(episode.airDate)).setHours(0, 0, 0, 0)) {
              series.data.comingUp = episode;
              break;
            }
          }
        }
        if (!appData.actorsNotDownloaded && appData.seriesSubscriptionStatusDownloaded) {
          progressBar = $("#request-progress-bar .progress-bar");
          progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
          return progressBar.addClass("progress-bar-success");
        }
      });
      if (!series.artworkUrl) {
        url = "/series/seriesId/" + series.id + "/banners";
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
              if (window.innerWidth < 505 || window.innerWidth > 1100) {
                series.currentArtworkUrl = series.artworkUrl;
              }
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
      } else {
        $('#blur-layer').css("background", "#fafafa url(" + appData.artworkUrl + ") 0 0 / cover");
        $('body').css("background", "#fafafa url(" + appData.artworkUrl + ") 0 0 / cover");
      }
      if (series.actors.length === 0) {
        url = "/series/seriesId/" + series.id + "/actors";
        $http.get(url).success(function(data) {
          var progressBar;
          series.actors = data;
          if (series.actors.length === 0) {
            appData.castAvailable = false;
          }
          appData.actorsNotDownloaded = false;
          if (!appData.seriesDataNotDownloaded && appData.seriesSubscriptionStatusDownloaded) {
            console.log("appdata is", appData.data);
            progressBar = $("#request-progress-bar .progress-bar");
            progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
            return progressBar.addClass("progress-bar-success");
          }
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
      return window.setTimeout(function() {
        var height;
        height = +$('#series').css('height').split('px')[0];
        console.log(height);
        return $('#blur-layer').css("height", height);
      }, 10000);
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

  app.directive('seriesSubscriptionDirective', [
    '$http', function($http) {
      return {
        link: function(scope, element, attrs) {
          $http.get("/subscriptions/getSeries?id=" + appData.id).success(function(result) {
            var progressBar;
            appData.seriesSubscriptionStatusDownloaded = true;
            console.log("series subscription status is", result);
            appData.seriesSubscriptionStatus = result.status;
            console.log("status", appData.seriesSubscriptionStatus);
            $("#subscribe,#unsubscribe").addClass("visibility-hidden");
            if (appData.seriesSubscriptionStatus) {
              $("#unsubscribe").removeClass("visibility-hidden");
            } else {
              $("#subscribe").removeClass("visibility-hidden");
            }
            if (!appData.seriesDataNotDownloaded && !appData.actorsNotDownloaded) {
              progressBar = $("#request-progress-bar .progress-bar");
              progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
              progressBar.addClass("progress-bar-success");
            }

            /*
            			progressBar = $("#request-progress-bar .progress-bar")
            			if result.err
            				progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
            				progressBar.addClass "progress-bar-danger"
            			else
            				progressBar.removeClass "progress-bar-striped progress-bar-success progress-bar-danger"
            				progressBar.addClass "progress-bar-success"
             */
          });
          $(element).find(">a").on('click', function(e) {
            var progressBar;
            e.preventDefault();
            console.log("clicking", appData.seriesSubscriptionStatus);
            $("#request-progress-bar").removeClass("display-none");
            $("#request-progress-bar .progress-bar").removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
            $("#request-progress-bar .progress-bar").addClass("progress-bar-striped");
            progressBar = $("#request-progress-bar .progress-bar");
            if (!appData.seriesSubscriptionStatus) {
              console.log("subscribing series ", appData.name);
              $http.get("/subscribe?name=" + appData.name + "&id=" + appData.id + "&artworkUrl=" + appData.artworkUrl + "&airsOnDayOfWeek=" + appData.data.airsOnDayOfWeek).success(function(result) {
                console.log("result", result);
                if (result.err) {
                  progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
                  progressBar.addClass("progress-bar-danger");
                  $("#not-signedin-error").modal();
                } else {
                  appData.seriesSubscriptionStatus = true;
                  progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
                  progressBar.addClass("progress-bar-success");
                  $("#subscribe,#unsubscribe").addClass("visibility-hidden");
                  $("#unsubscribe").removeClass("visibility-hidden");
                }
              });
            } else {
              console.log("unsubscribing the series");
              $http.get("/unsubscribe?id=" + appData.id).success(function(result) {
                console.log("result", result);
                if (result.err) {
                  progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
                  progressBar.addClass("progress-bar-danger");
                  $("#not-signedin-error").modal();
                } else {
                  appData.seriesSubscriptionStatus = false;
                  progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
                  progressBar.addClass("progress-bar-success");
                  $("#subscribe,#unsubscribe").addClass("visibility-hidden");
                  $("#subscribe").removeClass("visibility-hidden");
                }
              });
            }
          });
        }
      };
    }
  ]);

  app.directive('searchMoreSeriesDirective', [
    '$http', '$timeout', function($http, $timeout) {
      return {
        link: function(scope, element, attrs) {
          scope.search = {
            "query": "",
            "results": [],
            "makeQuery": function() {
              var query, url;
              query = encodeURIComponent(scope.search.query);
              url = "/series/seriesName/" + query;
              console.log("url", url);
              $http.get(url).success(function(data) {
                console.log("results", data);
                scope.search.results = data.seriesArray;
              });
            }
          };
        }
      };
    }
  ]);

  $(window).ready(function() {
    var height, width;
    if (navigator.platform !== "MacIntel") {
      $("html").niceScroll();
    }
    height = screen.height;
    width = screen.width;
    $('body').css("font-size", "" + (15 / 1280 * width) + "px");
    $("#search-more-series").on('click', function(e) {
      return $("#search-more-series #search-section").toggleClass('hidden');
    });
    $("#search-more-series input").on('click', function(e) {
      e.stopPropagation();
    });
  });

  $(window).resize(function() {
    var scope;
    scope = angular.element('body').scope();
    if (window.innerWidth > 504 && window.innerWidth < 1101) {
      scope.$apply(function() {
        scope.appController.appData.currentArtworkUrl = appData.altArtworkUrl;
      });
    } else {
      scope.$apply(function() {
        scope.appController.appData.currentArtworkUrl = appData.artworkUrl;
      });
    }
  });

}).call(this);


//# sourceMappingURL=app.js.map
