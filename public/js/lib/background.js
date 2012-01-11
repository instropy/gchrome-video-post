var d, getAllowedSites, getOption, getPrefix;
getPrefix = function() {
  return "cgt_";
};
getOption = function(key, value) {
  return localStorage[getPrefix() + key];
};
getAllowedSites = function() {
  return getOption('allowed_sites');
};
chrome.extension.onRequest.addListener(d = function(request, sender, sendResponse) {
  if (request.method === "getAllowedSites") {
    return sendResponse({
      result: getAllowedSites()
    });
  } else {
    return sendResponse({});
  }
});