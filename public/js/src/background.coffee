getPrefix = () -> "cgt_"
getOption = (key, value) -> localStorage[getPrefix()+key]
getAllowedSites = () -> getOption('allowed_sites')
chrome.extension.onRequest.addListener( d = (request,sender,sendResponse) ->
	if request.method == "getAllowedSites"
		sendResponse({result: getAllowedSites()})
	else
		sendResponse({})
)