
$('window').ready ->
	queryArray = []
	
	# downloadedBanners stores banners array for each series(key-id, value-bannersArray)
	downloadedBanners = {}
	selectedSeriesBanner = ""
	
	$('#search-field').on 'focus', (e) ->
		# displaying the exit button for distraction free search mode
		$('#close-distraction-free-search-mode i').removeClass 'display-none'
		

		$('#search-field').removeClass "animate-search-field restore-search-field"
		$('#div-blur-layer').removeClass "animate-blur-layer restore-blur-layer"
		$('#div-search-section').removeClass "animate-search-section restore-search-section"


		$('#search-field').addClass "animate-search-field"
		$('#div-blur-layer').addClass "animate-blur-layer"
		$('#div-search-section').addClass 'animate-search-section'
		return

	$('#close-distraction-free-search-mode i').on 'click', (event) ->
		
		$(this).toggleClass "display-none"
		$('#div-search-section').addClass 'restore-search-section'
		$('#search-field').addClass "restore-search-field"
		$('#div-blur-layer').addClass "restore-blur-layer"
		$('#search-results-container').empty()
		# window.setTimeOut $('#div-blur-layer').addClass "remove-blur-layer-background", 400
		return
		

	$('#search-field').on 'keyup', (e) ->
		if e.keyCode == 13
			$('#div-blur-layer').removeClass 'hidden'
			$('#div-blur-layer').addClass 'visible'
			
			progressIndicator = $("<div class='progress-indicator'><i class='fa fa-circle-o-notch fa-spin fa-5x'></i></div>")
			$('#search-results-container').prepend progressIndicator

			# so that progress indicator with respect to the corresponding search result is removed
			((progressIndicator, query) ->
				makeHttpRequestTo "http://localhost:8888/series/seriesName/#{query}", (data) ->
				#$('div#div-blur-layer').css({"visibilty":"show"})	
					#progressIndicator.remove()
					if data	
						data = JSON.parse data
						if data.seriesArray
							seriesArray = data.seriesArray
							
							###
						   searchResultContainer has 2 sections
						     1 - query section
						     2 - result section
							###

							currentSearchResultContainer = $("<div class='search-result'><div class='query'></div><div class='result'></div></div>")
							querySection  = currentSearchResultContainer.find('.query')
							resultSection = currentSearchResultContainer.find('.result')
							querySection.append $("<div>").append query
							
							
							
							# inserting the search result conatiner before its progress indicator, then removing the progress indicator 
							currentSearchResultContainer.insertBefore progressIndicator
							progressIndicator.remove()
							#$('#search-results-container').prepend currentSearchResultContainer
							((seriesArray, resultSection) ->
								for series in seriesArray
									resultSection.append $("<div class='search-result-n'>")
								
								counter = 1;
								for series in seriesArray
									console.log series
									searchResultN = resultSection.find ":nth-child(#{counter})"
									counter++

									searchResultN.attr "data-series-id","#{series.id}"
									searchResultN.attr "data-series-name","#{series.name}"

									
									###
									  storing name, id, banners of selected series to storage
									 	name ,id to determine series
									  banners to prevent again requesting for the data since banner data for specific series was already downlaoded
									###
									((searchResultN) ->
										searchResultN.on 'click', (event) ->
											#sessionStorage.setItem "series-name", searchResultN.data "series-name"
											#sessionStorage.setItem "series-id", searchResultN.data "series-id"

											#console.log  searchResultN.find ".series-artwork"
											if Modernizr.localstorage
												localStorage.setItem "series-banners", downloadedBanners[searchResultN.data "series-id"]
												localStorage.setItem "series-name", searchResultN.data "series-name"
												localStorage.setItem "series-id", searchResultN.data "series-id"
												#localStorage.setItem "series-artwork", searchResultN.find('img').attr 'href'
											else if Modernizr.sessionstorage
												sessionStorage.setItem "series-name", searchResultN.data "series-name"
												sessionStorage.setItem "series-id", searchResultN.data "series-id"
												sessionStorage.setItem "series-banners", downloadedBanners[searchResultN.data "series-id"]
												#sessionStorage.setItem "series-artwork", searchResultN.find('img').attr 'href'
											downloadedBanners = {}
									)(searchResultN)



									searchResultN.append $("<div class='img-tag'><span>#{series.name}</span></div>")
									#href = "./series.html?series-name=#{searchResultN.data 'series-name'}&series-id=#{searchResultN.data 'series-id'}"
									#searchResultN.append $("<a href='#{href}'>")

									((series, searchResultN) ->
										makeHttpRequestTo "http://localhost:8888/series/seriesId/#{series.id}/banners", (data) ->
											if data
												
		
												
												#	storing banners of each series to storage
												
												#localStorage.setItem "#{series.id}", data

												downloadedBanners["#{series.id}"] = data

												bannersArray = JSON.parse data
												#finding the required banner to show with result
												bannerUrl = ""
												for banner in bannersArray
													#console.log JSON.stringify banner
													if banner.type == "poster" #and banner.lanuage == "en"
														bannerUrl = banner.url
														break
												

												#resultSection.append $("<div><img src="+bannerUrl+"></img></div>")

												href = "./series.html?series-name=#{searchResultN.data 'series-name'}&series-id=#{searchResultN.data 'series-id'}"
												searchResultN.append $("<a href='#{href}'><img src="+bannerUrl+" class='series-artwork'></img></a>")

											return
										return
									)(series, searchResultN)
								return
							)(seriesArray, resultSection)
					return
				return
			)(progressIndicator, $('#search-field').val())
		return

	makeHttpRequestTo = (reqUrl, callback) ->
	  $.ajax
	    url: reqUrl
	    error: (jqXHR, textStatus, errorThrown) ->
	     #$('body').append "AJAX Error: #{textStatus}"
	      console.log 'error'
	      callback 
	        "errorStatus": "TRUE"
	      return
	    success: (data, textStatus, jqXHR) ->
	      #$('body').append "Successful AJAX call: #{data}"
	      #console.log data
	      callback data
	      return
		return

	return