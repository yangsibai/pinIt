chrome.browserAction.onClicked.addListener (tab)->
	if tab
		chrome.tabs.sendMessage tab.id, {args: ""}, (response) ->
			console.log response