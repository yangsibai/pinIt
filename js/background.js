// Generated by CoffeeScript 1.7.1
(function() {
  chrome.browserAction.onClicked.addListener(function(tab) {
    if (tab) {
      return chrome.tabs.sendMessage(tab.id, {
        args: ""
      }, function(response) {
        return console.log(response);
      });
    }
  });

}).call(this);

//# sourceMappingURL=background.map
