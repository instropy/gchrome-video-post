###$ = Qwery###
console.log "cgt extention init"
$.domReady( ->
	if !chrome || !chrome.tabs
		return
	console.log "am hyper ready"+$

	chrome.extension.onRequest.addListener((request, sender, sendResponse) ->
		console.log "addListener", request, sender, sendResponse
	)

	sendRequestCallbackHandler = (response) ->
		console.log "sendRequestCallbackHandler", response

	$.fn.getPageEmbeds = ->		
		chrome.tabs.getSelected(null, (tab) ->
			### gets an array reference of each objects tags in the current page ###
			###true && chrome.tabs.sendRequest tab.id, 'getSelection', 
			console.log "code tab.id "+tab.id###
			###chrome.tabs.update tab.id, {url:newUrl}###			
		)
		true
	###$.fn.getPageEmbeds.call(this)###
	true
)