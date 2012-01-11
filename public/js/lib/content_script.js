/*
Content script plugin
@insan3 01/11/2011
*/
var $_, addDisplayBox, getDocumentImages, getElementAttributes, getEmbeds, getOption, getPrefix, init, onPostEntry, sanitazise_title, sendFoundData;
getPrefix = function() {
  return "cgt_";
};
getOption = function(key, value) {
  return localStorage[getPrefix() + key];
};
$_ = function(selector) {
  return bonzo(qwery(selector));
};
addDisplayBox = function() {
  return $_('body').append('<div class="cgtBox loading"><div class="cgtBoxWrapper"><div id="cgtBoxInner"></div></div></div>');
};
sendFoundData = function(uri, data, callback) {
  var a_params, key, str_data, value, xhr;
  xhr = new XMLHttpRequest();
  xhr.open("POST", uri, false);
  str_data = 'frm=0&utm_source=chrome-ext';
  a_params = (function() {
    var _results;
    _results = [];
    for (key in data) {
      value = data[key];
      _results.push("&" + key + "=" + (escape(value)));
    }
    return _results;
  })();
  str_data += a_params.join('');
  /*Send the proper header information along with the request*/
  xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  /*
  	xhr.setRequestHeader "Content-length", str_data.length
  	*/
  xhr.onreadystatechange = function(wha) {
    /*console.log "onreadystatechange", xhr.readyState, xhr.status, wha*/    if (xhr.readyState === 4) {
      xhr.setRequestHeader("Connection", "close");
      return callback && callback(xhr.responseText);
    }
  };
  /*Send*/
  return xhr.send(str_data);
};
getDocumentImages = function(doc) {
  var images, imgs;
  images = document.getElementsByTagName('img');
  imgs = [];
  /*console.log('images', images)*/
  _.each(images, function(img) {
    var dim;
    dim = $_(img).dim();
    if (dim.width > 30 && dim.height > 30) {
      return imgs.push($_(img).attr('src'));
    }
  });
  /*console.log('imgs', imgs)*/
  return imgs;
};
getElementAttributes = function(el) {
  var a, attributes, value, _i, _len, _ref;
  attributes = {};
  /*console.log('el attributes', el, el.attributes)*/
  _ref = el.attributes;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    a = _ref[_i];
    value = a.value.replace(/\&/gi, '|');
    if ('flashvars' === a.name) {
      attributes[a.name] = value;
    }
  }
  return attributes;
};
getEmbeds = function(t) {
  /*e = document.getElementsByTagName('embed')*/
  var e, s, v, v_attrs, v_type;
  e = $_('embed, object');
  v = {};
  v_attrs = '';
  v_type = '';
  s = null;
  console.log('getEmbeds', e);
  /*_(e).each( (el,index) ->*/
  e.each(function(el, index) {
    v_type = el.localName;
    /*console.log 'v_type', el.nodeName, v_type*/
    if (v_type === 'embed') {
      /*choosing biggest embed*/
      if (!s || (s.attr('height') < $_(el).attr('height') && s.attr('width') < $_(el).attr('width'))) {
        s = $_(el);
        v_attrs = getElementAttributes(el);
      }
    } else {
      /*choosing biggest object*/
      if (!s || (s.attr('height') < $_(el).attr('height') && s.attr('width') < $_(el).attr('width'))) {
        s = $_(el);
        v_attrs = el.outerHTML;
      }
    }
    $_(el).css({
      'border': '2px solid #C14'
    });
    return console.log('object-embed html', v_attrs);
    /*
    		console.log index, el, $_(el).html()
    		console.log "flashvars", $_(el).attr('outerHTML')
    		*/
  });
  if (s) {
    v.attrs = v_attrs;
    v.src = s.attr('src');
    v.width = s.attr('width');
    v.height = s.attr('height');
    return {
      href: document.location.href,
      title: sanitazise_title(document.title),
      thumbs: getDocumentImages(null).join('|'),
      type: v_type,
      video: v
    };
  } else {
    return null;
  }
};
sanitazise_title = function(str) {
  var hostname;
  hostname = String(document.location.host).replace('www.', '');
  str = str.toLowerCase();
  str = str.replace('- ' + hostname, '');
  str = str.replace(hostname, '');
  console.log('sanitazise_title', str);
  return str;
};
onPostEntry = function(response) {
  console.log('onPostEntry', response);
  return setTimeout("$_('#cgtBoxInner').html('<p>Ok! done</p>') ^ $_('.cgtBox').addClass('ready')", 3000);
};
init = function() {
  var json;
  addDisplayBox();
  if (!this._best) {
    this._best = getEmbeds(this);
    json = JSON.stringify(this._best, null);
    if (this._best !== null && json) {
      sendFoundData('http://www.cogetube.com/api/', {
        jsonData: json,
        'action': 'post_entry'
      }, onPostEntry);
      /*
      			console.log('best', this._best, json)
      			send data, display info 
      			*/
      return $_('#cgtBoxInner').html('<p>Saving link</p>');
    } else {
      return $_('.cgtBox').remove();
    }
  } else {
    return $_('.cgtBox').remove();
  }
};
/* beauty at its finest */
domReady((function() {
  return chrome.extension.sendRequest({
    method: "getAllowedSites"
  }, function(response) {
    var allowThis, allowedSites, e, f, host;
    allowedSites = (response.result || "\n").split("\n") || [];
    allowThis = false;
    host = document.location.host;
    console.log('?sites', allowedSites);
    if (allowedSites.length > 0) {
      f = function(b) {
        if (b) {
          setTimeout('!init()', 2000);
        }
        return b;
      };
      e = function(sites) {
        var s, site, _i, _j, _len, _len2, _results;
        for (_i = 0, _len = sites.length; _i < _len; _i++) {
          s = sites[_i];
          console.log('?is', s, host);
        }
        _results = [];
        for (_j = 0, _len2 = sites.length; _j < _len2; _j++) {
          site = sites[_j];
          _results.push(f(site === host || host === String('www.' + site + '')));
        }
        return _results;
      };
      e(allowedSites);
      delete e;
      delete f;
    }
    return console.log('?sites', 'host', 'allowThis', allowedSites, host, allowThis);
  });
}));