/*$ = Qwery*/console.log("cgt extention init");
$.domReady(function() {
  var sendRequestCallbackHandler;
  if (!chrome || !chrome.tabs) {
    return;
  }
  console.log("am hyper ready" + $);
  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    return console.log("addListener", request, sender, sendResponse);
  });
  sendRequestCallbackHandler = function(response) {
    return console.log("sendRequestCallbackHandler", response);
  };
  $.fn.getPageEmbeds = function() {
    chrome.tabs.getSelected(null, function(tab) {
      /* gets an array reference of each objects tags in the current page */
      /*true && chrome.tabs.sendRequest tab.id, 'getSelection', 
      			console.log "code tab.id "+tab.id*/
      /*chrome.tabs.update tab.id, {url:newUrl}*/
    });
    return true;
  };
  /*$.fn.getPageEmbeds.call(this)*/
  return true;
});