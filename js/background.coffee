serverAddress = "http://heshui.la"

chrome.browserAction.onClicked.addListener (tab)->
	if tab
		chrome.tabs.sendMessage tab.id,
			cmd: "new"
			pins: getLocalPin(tab.url)
		, (data) ->
			console.dir data

		getRemotePin tab.url, (err, pins)->
			if err
				alert(err.message)
			else if pins and pins.length > 0
				chrome.tabs.sendMessage tab.id,
					cmd: "data"
					pins: pins
				, (data)->
					console.dir data

chrome.runtime.onMessage.addListener (request, sender, sendResponse)->
	request.data.url = sender.url
	request.data.title = sender.tab.title
	newPin(request.data)

###
    set browser action badge and title
###
chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) ->
	$.get "#{serverAddress}/pin/countOnPage",
		url: tab.url
	, (res)->
		if res.code is 0
			chrome.browserAction.setBadgeText
				text: res.count + ""
				tabId: tabId
			chrome.browserAction.setBadgeBackgroundColor
				color: "#F00"
				tabId: tabId
			chrome.browserAction.setTitle
				title: "#{res.count} pin"
				tabId: tabId

###
    create new pin
###
newPin = (data) ->
	#send to remote server
	$.post "#{serverAddress}/pin/new", data, (res)->
		if res.code isnt 0
			alert(res.message)

	saveLocal(data)

###
    save in local storage
###
saveLocal = (data)->
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

###
    get local pins
###
getLocalPin = (url)->
	if localStorage and localStorage.data
		storage = JSON.parse(localStorage.data)
		for item in storage
			if item.url is url
				return item.pins
	return []

###
    get pin from remote server
###
getRemotePin = (url, cb)->
	$.get "#{serverAddress}/pin/pinOnPage", {
		url: url
	}, (res)->
		if res.code is 0
			cb null, res.pins
			for pin in res.pins
				saveLocal(pin)
		else
			cb new Error(res.message)