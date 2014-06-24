chrome.browserAction.onClicked.addListener (tab)->
	if tab
		title = tab.title
		url = tab.url
		chrome.tabs.sendMessage tab.id, {args: ""}, (x, y, text) ->
			console.log x, y, text