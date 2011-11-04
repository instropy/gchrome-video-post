###
extentiont OPTIONS
###

###wrap dom utility with selector engine ###
bonzo.setQueryEngine(qwery)
cgt = (selector) -> bonzo(qwery(selector))
get = (selector) -> qwery(selector)

getPrefix = () -> "cgt_"
setOption = (key, value) -> localStorage[getPrefix()+key] = value
getOption = (key, value) -> localStorage[getPrefix()+key]
updateStatus = (message) -> cgt('#message_box').html('<p>'+message+'</p>')


page_saveOptions = (evt) ->
	console.log 'page_saveOptions'
	cgt('input, textarea, select').each( (e,i) ->
		console.log cgt(e).attr('id'), cgt(e).val()
		setOption cgt(e).attr('id'), cgt(e).val()
	)
	updateStatus 'Options successfully saved'

page_onLoad = (evt) ->
	
	
	### bind events ###
	button = qwery('#saveOptionsBtn')[0]
	bean.add button, 'click', page_saveOptions, null

	console.log button

	###date = if friday then sue else jill###

	sites = getOption('allowed_sites')
	sites or= ''
	cgt('#allowed_sites').text(sites)


###DOMContentLoaded###
domReady(page_onLoad)