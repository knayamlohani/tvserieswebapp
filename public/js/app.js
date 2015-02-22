(function(){var e,t;t={name:"",id:"",banners:"",actors:[],data:{},artworkUrl:"",host:"http://tvserieswebapp.herokuapp.com",backgroundImageUrl:""},Modernizr.localstorage?(t.name=localStorage.getItem("series-name"),t.id=localStorage.getItem("series-id"),t.banners=JSON.parse(localStorage.getItem("series-banners"))):Modernizr.sessionstorage&&(t.name=sessionStorage.getItem("series-name"),t.id=sessionStorage.getItem("series-id"),t.banners=JSON.parse(sessionStorage.getItem("series-banners"))),window.location.href.split("?")[1]&&(t.name=decodeURIComponent(window.location.href.split("?")[1].split("&")[0].split("=")[1]),t.id=decodeURIComponent(window.location.href.split("?")[1].split("&")[1].split("=")[1]),t.artworkUrl=decodeURIComponent(window.location.href.split("?")[1].split("&")[2].split("=")[1])),e=angular.module("app",[]),e.controller("controller",["$scope","$http",function(e,r){var n,i;return this.appData=t,this.appData.actorsNotDownloaded=!0,this.appBehavior={},n=this.appData,n.castAvailable=!0,this.appBehavior.getCastAvailabilityCurrently=function(){return n.actors!==[0]},i="/series/seriesId/"+n.id+"/seriesOnly",r.get(i).success(function(e){return n.data=e}),n.artworkUrl?($("#blur-layer").css("background","#fafafa url("+t.artworkUrl+") 0 0 / cover"),$("body").css("background","#fafafa url("+t.artworkUrl+") 0 0 / cover")):(i="/series/seriesId/"+n.id+"/banners",r.get(i).success(function(e){var r,i,o,s,a,l;for(n.banners=e,r=!1,i=!1,l=n.banners,s=0,a=l.length;a>s&&(o=l[s],!r||!i);s++)"poster"!==o.type||r||(n.artworkUrl=o.url,r=!0),"fanart"!==o.type||i||(n.backgroundImageUrl=o.url,i=!0);return $("#blur-layer").css("background","#fafafa url("+t.artworkUrl+") 0 0 / cover"),$("body").css("background","#fafafa url("+t.artworkUrl+") 0 0 / cover")})),0===n.actors.length?(i="/series/seriesId/"+n.id+"/actors",r.get(i).success(function(e){return n.actors=e,0===n.actors.length&&(t.castAvailable=!1),t.actorsNotDownloaded=!1}),e.globalClick=!1):void 0}]),e.directive("episodeDirective",["$timeout",function(e){return function(t,r,n){return e(function(){t.$apply(function(){t.episode.name&&"TBA"!==t.episode.name||(t.episode.name="To Be Anounced")}),$(angular.element(r)).click(function(){var e;$(".episode-title").not($(this)).removeClass("selected"),$(this).toggleClass("selected"),$(".episode-title").not($(this)).parent().find(".episode-body").addClass("display-none"),e=$(this).parent().find(".episode-body"),e.toggleClass("display-none"),"MacIntel"===navigator.platform||e.hasClass("nice-scrolled"&&!e.hasClass("display-none"))||(console.log("MacIntel"===navigator.platform),e.niceScroll(),e.addClass("nice-scrolled"))})})}}]),e.directive("actorTemplate",function(){return{restrict:"E",templateUrl:"templates/actor-template.html"}}),e.directive("seasonDirective",function(){return function(e,r,n){var i,o;o=e.$index,i=+t.data.seasons[o].episodes.length,i%2===0?i/=2:i=i/2+1}}),e.filter("sliceFirstHalf",function(){return function(e){var t;return t=e.length%2===1?(e.length+1)/2:e.length/2,(e||[]).slice(0,t)}}),e.filter("sliceSecondHalf",function(){return function(e){var t;return t=e.length%2===0?e.length/2:(e.length+1)/2,(e||[]).slice(t,e.length)}}),e.directive("blurLayerDirective",function(){return function(e,t,r){}}),e.directive("allSeasonsDirective",function(){return function(e,t,r){var n;return n=+$("#series").css("height").split("px")[0]+ +$("#seasons-container").css("height").split("px")[0],$("#blur-layer").css("height",n)}}),e.directive("seriesOverviewBodyDirective",["$timeout",function(e){return function(e,t,r){return"MacIntel"===navigator.platform||$("#overview-body").hasClass("nice-scrolled")?void 0:(t.niceScroll(),t.addClass("nice-scrolled"))}}]),e.directive("actorDescriptionDirective",function(){return{link:function(e,t,r){console.log("actor-description"),"MacIntel"===navigator.platform||t.hasClass("nice-scrolled")||(t.niceScroll(),t.addClass("nice-scrolled"))}}}),e.directive("allActorsDirective",["$timeout",function(e){return{link:function(r,n,i){e(function(){return console.log(" cast "+t.actors)}),0===t.actors.length&&console.log("no cast details")}}}]),e.directive("seriesSubscriptionDirective",["$http",function(e){return{link:function(r,n,i){$(n).find(">a").on("click",function(r){r.preventDefault(),console.log("subscribing series ",t.name),e.get("/subscribe?name="+t.name+"&id="+t.id+"&artworkUrl="+t.artworkUrl).success(function(e){console.log("result",e)})})}}}]),$("window").ready(function(){var e,t;return"MacIntel"!==navigator.platform&&$("html").niceScroll(),e=screen.height,t=screen.width,$("body").css("font-size",""+15/1280*t+"px")})}).call(this);
//# sourceMappingURL=./app.js.map