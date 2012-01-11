###
Content script plugin
@insan3 01/11/2011
###

getPrefix = () -> "cgt_"
getOption = (key, value) -> localStorage[getPrefix()+key]

#wrap dom utility with selector engine ###
$_ = (selector) -> bonzo(qwery(selector))

addDisplayBox = () ->
	$_('body').append('<div class="cgtBox loading"><div class="cgtBoxWrapper"><div id="cgtBoxInner"></div></div></div>')

sendFoundData = (uri, data, callback) ->
	xhr = new XMLHttpRequest();
	xhr.open("POST", uri, false)

	str_data = 'frm=0&utm_source=chrome-ext'

	a_params = for key, value of data
		"&#{key}=#{escape(value)}"

	str_data+=a_params.join('')
	
	###Send the proper header information along with the request###

	xhr.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
	
	###
	xhr.setRequestHeader "Content-length", str_data.length
	###
	
	xhr.onreadystatechange = (wha) ->
		###console.log "onreadystatechange", xhr.readyState, xhr.status, wha###
		if xhr.readyState == 4
			xhr.setRequestHeader "Connection", "close"
			callback && callback(xhr.responseText)

	###Send###

	xhr.send(str_data)


getDocumentImages = (doc) ->	
	images = document.getElementsByTagName('img')
	imgs = []

	###console.log('images', images)###
	_.each(images, (img) ->
		dim = $_(img).dim()
		if dim.width>30 && dim.height>30
			imgs.push($_(img).attr('src'))
	)
	###console.log('imgs', imgs)###
	imgs

#returns object containing element attributes###
getElementAttributes = (el) ->
	attributes = {}	
	###console.log('el attributes', el, el.attributes)###
	for a in el.attributes
		value = a.value.replace(/\&/gi, '|')
		if 'flashvars' == a.name
			attributes[a.name] = value
	attributes
		
getEmbeds = (t) ->	

	###e = document.getElementsByTagName('embed')###
	e = $_('embed, object')	
	v = {}
	v_attrs = ''
	v_type = ''
	s = null
	
	console.log 'getEmbeds', e

	###_(e).each( (el,index) ->###
	e.each( (el,index) ->
		v_type = el.localName
		###console.log 'v_type', el.nodeName, v_type###
		if v_type == 'embed'			
			###choosing biggest embed###
			if !s || (s.attr('height') < $_(el).attr('height') && s.attr('width') < $_(el).attr('width'))
				s = $_(el)
				v_attrs = getElementAttributes(el)
		else
			###choosing biggest object###
			if !s || (s.attr('height') < $_(el).attr('height') && s.attr('width') < $_(el).attr('width'))
				s = $_(el)				
				v_attrs = el.outerHTML
			
		$_(el).css { 'border' : '2px solid #C14'}
		
		console.log 'object-embed html', v_attrs

		###
		console.log index, el, $_(el).html()
		console.log "flashvars", $_(el).attr('outerHTML')
		###
	)
	
	if s
		
		v.attrs = v_attrs
		v.src = s.attr('src')
		v.width = s.attr('width')
		v.height = s.attr('height')
		
		return {href : document.location.href
		title : sanitazise_title(document.title)
		thumbs : getDocumentImages(null).join('|')		
		type : v_type
		video : v
		}
	else
		return null

sanitazise_title = (str) ->
	hostname = String(document.location.host).replace('www.','')
	str = str.toLowerCase()	
	str = str.replace('- '+hostname, '')
	str = str.replace(hostname, '')
	console.log 'sanitazise_title', str
	str

onPostEntry = (response) ->
	console.log 'onPostEntry', response		
	setTimeout("$_('#cgtBoxInner').html('<p>Ok! done</p>') ^ $_('.cgtBox').addClass('ready')", 3000)

init = () ->
	addDisplayBox()
	if !this._best
		this._best = getEmbeds(this)
		json = JSON.stringify( this._best , null)
		if this._best != null && json			
			sendFoundData('http://www.cogetube.com/api/', {jsonData : json, 'action' : 'post_entry'}, onPostEntry)
			###
			console.log('best', this._best, json)
			send data, display info 
			###			
			$_('#cgtBoxInner').html('<p>Saving link</p>')
		else
			$_('.cgtBox').remove()
	else
		$_('.cgtBox').remove()

### beauty at its finest ###

domReady ( () ->
	chrome.extension.sendRequest({method: "getAllowedSites"}
	, (response) ->
		allowedSites = (response.result||"\n").split("\n")||[]
		allowThis = false
		host = document.location.host
		console.log '?sites', allowedSites
		if 	allowedSites.length > 0
			f = ( b ) ->
				setTimeout('!init()', 2000) if b
				b
			e = ( sites ) ->				
				console.log('?is', s, host) for s in sites
				f(site is host || host is String('www.'+site+'')) for site in sites
				
			e allowedSites
			delete e
			delete f
		console.log '?sites', 'host','allowThis', allowedSites, host, allowThis
	)
)