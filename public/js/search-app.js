// Generated by CoffeeScript 1.8.0
(function() {
  var searchApp, searchQuery;

  searchQuery = "";

  $('window').ready(function() {
    $('body').css("font-size", "" + (15 / 1280 * screen.width) + "px");
    if (navigator.platform !== "MacIntel") {
      $("html").niceScroll();
    }
    $('#search-field').on('focus', function(e) {
      $('#close-distraction-free-search-mode i').removeClass('display-none');
      $('#search-field').removeClass("animate-search-field restore-search-field");
      $('#div-blur-layer').removeClass("animate-blur-layer restore-blur-layer");
      $('#div-search-section').removeClass("animate-search-section restore-search-section");
      $('#search-field').addClass("animate-search-field");
      $('#div-blur-layer').addClass("animate-blur-layer");
      $('#div-search-section').addClass('animate-search-section');
    });
    $('#close-distraction-free-search-mode i').on('click', function(event) {
      $('.progress-indicator').toggleClass('display-none');
      $(this).toggleClass("display-none");
      $('#div-search-section').addClass('restore-search-section');
      $('#search-field').addClass("restore-search-field");
      $('#div-blur-layer').addClass("restore-blur-layer");
      $('#search-results-container').empty();
    });
    return $('#search-field').on('keyup', function(event) {
      if (event.keyCode === 13) {
        $('.progress-indicator').removeClass('display-none');
        console.log("search");
      }
    });
  });

  searchApp = angular.module('search-app', []);

  searchApp.controller('controller', [
    '$scope', '$http', function($scope, $http) {
      $scope.appData = {};
      $scope.appBehavior = {};
      $scope.appData.allSearchResultsData = [];
      $scope.appData.progressIndicatorStatus = false;
      $scope.appData.currentArtworkUrl = "";
      $scope.appData.searchRequestCompletedStatus = false;
      $scope.appData.user = {
        "first-name": "",
        "email": "",
        "username": "",
        "signed-in": ""
      };
      $scope.appBehavior.onKeyUp = function(event) {
        var url;
        if (event.keyCode === 13) {
          console.log($scope.appData.searchQuery);
          $scope.appData.progressIndicatorStatus = true;
          $scope.appData.searchRequestCompletedStatus = false;
          searchQuery = encodeURIComponent($scope.appData.searchQuery);
          url = "/series/seriesName/" + searchQuery;
          $http.get(url).success(function(data) {
            var currentSearchResultsData, series, _fn, _i, _len, _ref;
            $scope.appData.progressIndicatorStatus = false;
            if (data.seriesArray) {
              currentSearchResultsData = {
                "currentSearchQuery": $scope.appData.searchQuery,
                "currentSearchResults": []
              };
              $scope.appData.allSearchResultsData.push(currentSearchResultsData);
              _ref = data.seriesArray;
              _fn = function(series, currentSearchResultsData) {
                $http.get(url).success(function(data) {
                  var banner, _j, _len1;
                  console.log(series.name);
                  for (_j = 0, _len1 = data.length; _j < _len1; _j++) {
                    banner = data[_j];
                    console.log("windows.availheight", window.innerWidth);
                    if (banner.type === "poster") {
                      currentSearchResultsData.currentSearchResults.push({
                        "name": series.name,
                        "id": series.id,
                        "bannerUrl": banner.url,
                        "altBannerUrl": series.banner,
                        "currentBannerUrl": window.innerWidth <= 800 ? series.banner : banner.url
                      });
                      break;
                    }
                  }
                  $scope.appData.searchRequestCompletionStatus = true;
                });
              };
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                series = _ref[_i];
                url = "/series/seriesId/" + series.id + "/banners";
                _fn(series, currentSearchResultsData);
              }
            } else {
              console.log("no matching results found");
            }
          });
        }
      };
      $scope.appBehavior.viewSeries = function(event) {
        console.log("series clicked");
        return;
        return $scope.appBehavior.restAppData = function() {
          $scope.appData.allSearchResultsData = [];
          $scope.appData.searchQuery = "";
        };
      };
      return $scope.appBehavior.ifDataAvailable = function(data) {
        console.log(data);
        if (data && data.length() > 0) {
          return true;
        }
        return false;
      };
    }
  ]);

  searchApp.directive('currentSearchResultsDirective', function() {
    return function(scope, element, attrs) {
      window.setTimeout(function() {
        return $('#div-blur-layer').css("height", $('#div-search-section').css("height"));
      }, 4000);
    };
  });

  $(window).resize(function() {
    var scope;
    scope = angular.element('#div-search-section').scope();
    if (window.innerWidth <= 800) {
      scope.$apply(function() {
        var allSearchResults, searchResult, _i, _j, _len, _len1, _ref, _ref1;
        _ref = scope.appData.allSearchResultsData;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          allSearchResults = _ref[_i];
          _ref1 = allSearchResults.currentSearchResults;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            searchResult = _ref1[_j];
            searchResult.currentBannerUrl = searchResult.altBannerUrl;
          }
        }
      });
    } else {
      scope.$apply(function() {
        var allSearchResults, searchResult, _i, _j, _len, _len1, _ref, _ref1;
        _ref = scope.appData.allSearchResultsData;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          allSearchResults = _ref[_i];
          _ref1 = allSearchResults.currentSearchResults;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            searchResult = _ref1[_j];
            searchResult.currentBannerUrl = searchResult.bannerUrl;
          }
        }
      });
    }
  });

}).call(this);


//# sourceMappingURL=search-app.js.map
