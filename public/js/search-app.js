(function(){var e,a;a="",$("window").ready(function(){return $("body").css("font-size",""+15/1280*screen.width+"px"),"MacIntel"!==navigator.platform&&$("html").niceScroll(),$("#search-field").on("focus",function(e){$("#close-distraction-free-search-mode i").removeClass("display-none"),$("#search-field").removeClass("animate-search-field restore-search-field"),$("#div-blur-layer").removeClass("animate-blur-layer restore-blur-layer"),$("#div-search-section").removeClass("animate-search-section restore-search-section"),$("#search-field").addClass("animate-search-field"),$("#div-blur-layer").addClass("animate-blur-layer"),$("#div-search-section").addClass("animate-search-section")}),$("#close-distraction-free-search-mode i").on("click",function(e){$(".progress-indicator").toggleClass("display-none"),$(this).toggleClass("display-none"),$("#div-search-section").addClass("restore-search-section"),$("#search-field").addClass("restore-search-field"),$("#div-blur-layer").addClass("restore-blur-layer"),$("#search-results-container").empty()}),$("#search-field").on("keyup",function(e){13===e.keyCode&&($(".progress-indicator").removeClass("display-none"),console.log("search"))})}),e=angular.module("search-app",[]),e.controller("controller",["$scope","$http",function(e,r){return e.appData={},e.appBehavior={},e.appData.allSearchResultsData=[],e.appData.host="http://tvserieswebapp.herokuapp.com",e.appData.progressIndicatorStatus=!1,e.appData.user={"first-name":"",email:"",username:"","signed-in":""},e.appBehavior.onKeyUp=function(s){var t;13===s.keyCode&&(console.log(e.appData.searchQuery),e.appData.progressIndicatorStatus=!0,a=encodeURIComponent(e.appData.searchQuery),t="/series/seriesName/"+a,r.get(t).success(function(a){var s,i,o,n,c,l;if(e.appData.progressIndicatorStatus=!1,a.seriesArray)for(s={currentSearchResults:[]},e.appData.allSearchResultsData.push(s),l=a.seriesArray,o=function(e,a){r.get(t).success(function(r){var s,t,i;for(console.log(e.name),t=0,i=r.length;i>t;t++)if(s=r[t],"poster"===s.type){a.currentSearchResults.push({name:e.name,id:e.id,bannerUrl:s.url});break}})},n=0,c=l.length;c>n;n++)i=l[n],t="/series/seriesId/"+i.id+"/banners",o(i,s)}))},e.appBehavior.viewSeries=function(a){return void console.log("series clicked");return e.appBehavior.restAppData=function(){e.appData.allSearchResultsData=[],e.appData.searchQuery=""}},e.appBehavior.ifDataAvailable=function(e){return console.log(e),e&&e.length()>0?!0:!1}}]),e.directive("currentSearchResultsDirective",function(){return function(e,a,r){$("#div-blur-layer").css("height",$("#div-search-section").css("height"))}})}).call(this);
//# sourceMappingURL=./search-app.js.map