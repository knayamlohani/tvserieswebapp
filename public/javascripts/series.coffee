$('window').ready ->
	request = (reqUrl, callback) ->
	  $.ajax
	    url: reqUrl
	    error: (jqXHR, textStatus, errorThrown) ->
	      console.log 'error'
	      callback 
	        "errorStatus": "TRUE"
	      return
	    success: (data, textStatus, jqXHR) ->
	      callback data
	      return
	  return

	seriesName = ""
	seriesId   = ""
	seriesBanners = []
	seriesActors = []
	seriesData = {}
	seriesArtwork = ""


	if Modernizr.localstorage
		seriesName    = localStorage.getItem "series-name"
		seriesId      = localStorage.getItem "series-id"
		seriesBanners = JSON.parse localStorage.getItem "series-banners"
	else if Modernizr.sessionstorage
		seriesName    = sessionStorage.getItem "series-name"
		seriesId      = sessionStorage.getItem "series-id"
		seriesBanners = JSON.parse sessionStorage.getItem "series-banners"
	else
		if window.location.href.split('?')[1]
			seriesName = ((window.location.href.split('?')[1]).split("&")[0]).split('=')[1]
			seriesId   = ((window.location.href.split('?')[1]).split("&")[1]).split('=')[1]

	$("#series-title").append seriesName


	# seriesBanners already available in storage
	if !seriesBanners
		request "http://localhost:8888/series/seriesId/#{seriesId}/banners", (data) ->
			#localStorage.setItem "series-data", data
			console.log "making bannes reques"
			if data
				seriesBanners = data
			return

	request "http://localhost:8888/series/seriesId/#{seriesId}", (data) ->
		#localStorage.setItem "series-data", data
		return

	

	

	return