chrome.browserAction.onClicked.addListener (tab)->
	if tab
		title = tab.title
		url = tab.url
		chrome.tabs.sendMessage tab.id, {args: ""}, (x, y, text) ->
			console.log x, y, text
			alert x

chrome.runtime.onMessage.addListener (request, sender, sendResponse)->
	console.dir sender
	console.dir request