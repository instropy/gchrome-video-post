/*
extentiont OPTIONS
*/
/*wrap dom utility with selector engine */
var cgt, get, getOption, getPrefix, page_onLoad, page_saveOptions, setOption, updateStatus;
bonzo.setQueryEngine(qwery);
cgt = function(selector) {
  return bonzo(qwery(selector));
};
get = function(selector) {
  return qwery(selector);
};
getPrefix = function() {
  return "cgt_";
};
setOption = function(key, value) {
  return localStorage[getPrefix() + key] = value;
};
getOption = function(key, value) {
  return localStorage[getPrefix() + key];
};
updateStatus = function(message) {
  return cgt('#message_box').html('<p>' + message + '</p>');
};
page_saveOptions = function(evt) {
  console.log('page_saveOptions');
  cgt('input, textarea, select').each(function(e, i) {
    console.log(cgt(e).attr('id'), cgt(e).val());
    return setOption(cgt(e).attr('id'), cgt(e).val());
  });
  return updateStatus('Options successfully saved');
};
page_onLoad = function(evt) {
  /* bind events */
  var button, sites;
  button = qwery('#saveOptionsBtn')[0];
  bean.add(button, 'click', page_saveOptions, null);
  console.log(button);
  /*date = if friday then sue else jill*/
  sites = getOption('allowed_sites');
  sites || (sites = '');
  return cgt('#allowed_sites').text(sites);
};
/*DOMContentLoaded*/
domReady(page_onLoad);