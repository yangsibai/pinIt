chrome.browserAction.onClicked.addListener (tab)->
	if tab
		chrome.tabs.sendMessage tab.id,
			pins: getPin(tab.url)
		, (data) ->
			console.dir data

chrome.runtime.onMessage.addListener (request, sender, sendResponse)->
	request.data.url = sender.url
	request.data.title = sender.tab.title
	newPin(request.data)

newPin = (data) ->
	if localStorage and localStorage.data
		storage = JSON.parse(localStorage.data);
	else
		storage = []

	for item in storage
		if item.url is data.url
			foundURL = true
			for pin in item.pins
				if pin.x is data.x and pin.y is data.y
					foundPIN = true
					pin.text = data.text
					break
			unless foundPIN
				item.pins.push
					x: data.x
					y: data.y
					text: data.text
			break

	unless foundURL
		storage.push
			url: data.url
			title: data.title
			pins: [
				x: data.x
				y: data.y
				text: data.text
			]

	localStorage.data = JSON.stringify(storage)

getPin = (url)->
	if localStorage and localStorage.data
		storage = JSON.parse(localStorage.data)
		for item in storage
			if item.url is url
				return item.pins

	[]