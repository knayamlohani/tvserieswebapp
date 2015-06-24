// Generated by CoffeeScript 1.8.0
(function() {
  var dashboardApp;

  $('window').ready(function() {
    $('#options-bar .option').on('click', function(e) {
      var allOptionsBarOptions, allOptionsBarOptionsContent, selectedOptionsBarOptionContent, selectedOptionsBarOptionContentLink;
      $("#options-bar .option").removeClass("active not-active");
      $(this).addClass("active");
      allOptionsBarOptions = $('#options-bar .option');
      allOptionsBarOptions.not($(this)).addClass('not-active');
      selectedOptionsBarOptionContentLink = $(this).data('link');
      console.log(selectedOptionsBarOptionContentLink);
      allOptionsBarOptionsContent = $('#options-bar-content .options-bar-option-content');
      allOptionsBarOptionsContent.removeClass("active");
      allOptionsBarOptionsContent.removeClass("not-active");
      selectedOptionsBarOptionContent = $("#options-bar-content .options-bar-option-content[data-link='" + selectedOptionsBarOptionContentLink + "']");
      selectedOptionsBarOptionContent.addClass("active");
      allOptionsBarOptionsContent.not(selectedOptionsBarOptionContent).addClass('not-active');
      console.log(selectedOptionsBarOptionContent);
    });
  });

  dashboardApp = angular.module('dashboard-app', []);

  dashboardApp.controller('dashboard-controller', [
    '$http', '$scope', function($http, $scope) {
      console.log("setting controller");
      $scope.appData = {};
      $scope.appData.subscribedTvShows = [];
      $scope.appData.tvShowsToBeUnsubscribed = [];
      $scope.appData.requestingSubscribedTvShows = true;
      $scope.appData.downloadedSubscribedTvShows = false;
      $scope.appData.days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
      $scope.appData.ifTvShowsAiringToday = function(airDay) {
        var series, _i, _len, _ref;
        _ref = $scope.appData.subscribedTvShows;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          series = _ref[_i];
          if (series.airsOnDayOfWeek === airDay) {
            return true;
          }
        }
        return false;
      };
    }
  ]);

  dashboardApp.directive('subscriptionsDirective', [
    '$timeout', '$http', function($timeout, $http) {
      return {
        link: function(scope, element, attrs) {
          $(element).on('click', function(e) {
            $http.get('/subscriptions').success(function(result) {
              var progressBar;
              console.log("dashboard result ", result);
              scope.appData.requestingSubscribedTvShows = false;
              scope.appData.downloadedSubscribedTvShows = true;
              scope.appData.subscribedTvShows = result.data;
              progressBar = $("#request-progress-bar .progress-bar");
              progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
              return progressBar.addClass("progress-bar-success");
            });
          });
          element.trigger('click');
        }
      };
    }
  ]);

  dashboardApp.directive('subscribedTvShowDirective', [
    '$timeout', '$http', function($timeout, $http) {
      return {
        link: function(scope, element, attrs) {
          $(element).on('click', function(e) {
            $(this).toggleClass('unsubscribe');
            $(this).find('.remove-series-indicator').toggleClass('display');
            if ($('.subscribed-tv-show.unsubscribe').length > 0) {
              $("#unsubscribe-tv-shows").addClass('visible');
            } else {
              $("#unsubscribe-tv-shows").removeClass('visible');
            }
          });
        }
      };
    }
  ]);

  dashboardApp.directive('unsubscribeSelectedTvShowsDirective', [
    '$timeout', function($timeout) {
      return {
        link: function(scope, elemement, attrs) {
          elemement.on('click', function(e) {
            var tvShowsToBeUnsubscribed;
            console.log("unsubscribing the following tv shows");
            tvShowsToBeUnsubscribed = [];
            $(".unsubscribe").each(function() {
              var series;
              series = $(this);
              tvShowsToBeUnsubscribed.push({
                "id": series.data("seriesId"),
                "name": series.data("seriesName"),
                "airsOnDayOfWeek": series.data("airsOnDayOfWeek")
              });
            });
            $timeout(function() {
              scope.$apply(function() {
                scope.appData.tvShowsToBeUnsubscribed = tvShowsToBeUnsubscribed;
              });
            });
            $('#modal-tv-shows-to-be-unsubscribed').modal();
          });
        }
      };
    }
  ]);

  dashboardApp.directive('confirmUnsubscribeDirective', [
    '$timeout', '$http', function($timeout, $http) {
      return {
        link: function(scope, elemement, attrs) {
          elemement.on('click', function(e) {
            var progressBar, series, tvShowsToBeUnsubscribed, _i, _len, _ref;
            $('#modal-tv-shows-to-be-unsubscribed').modal();
            progressBar = $("#request-progress-bar .progress-bar");
            progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
            progressBar.addClass("progress-bar-striped");
            tvShowsToBeUnsubscribed = [];
            _ref = scope.appData.tvShowsToBeUnsubscribed;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              series = _ref[_i];
              tvShowsToBeUnsubscribed.push({
                "id": series.id
              });
            }
            $http.post('/unsubscribe', {
              "tvShowsToBeUnsubscribed": tvShowsToBeUnsubscribed
            }).success(function(data, status, headers, config) {
              console.log("success unsubscribing", data);
              progressBar.removeClass("progress-bar-striped progress-bar-success progress-bar-danger");
              progressBar.addClass("progress-bar-success");
              console.log("tv shows all", scope.appData.subscribedTvShows);
              if (!data.err) {
                $timeout(function() {
                  var remove, _j, _len1, _ref1;
                  _ref1 = scope.appData.tvShowsToBeUnsubscribed;
                  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                    remove = _ref1[_j];
                    scope.appData.subscribedTvShows.splice(remove, 1);
                  }
                });
              }
            }).error(function(data, status, headers, config) {});
          });
        }
      };
    }
  ]);

  dashboardApp.filter('filterTvShowsByAirDay', function() {
    return function(seriesArray, airDay) {
      var series, seriesAiringOnDay, _i, _len;
      seriesAiringOnDay = [];
      for (_i = 0, _len = seriesArray.length; _i < _len; _i++) {
        series = seriesArray[_i];
        if (series.airsOnDayOfWeek === airDay) {
          seriesAiringOnDay.push(series);
        }
      }
      return seriesAiringOnDay;
    };
  });

}).call(this);


//# sourceMappingURL=dashboard.js.map
