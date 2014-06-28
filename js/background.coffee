serverAddress = "http://api.heshui.la"

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
	ajax.get "#{serverAddress}/pin/countOnPage",
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
	ajax.post "#{serverAddress}/pin/new", data, (res)->
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
	ajax.get "#{serverAddress}/pin/pinOnPage", {
		url: url
	}, (res)->
		if res.code is 0
			cb null, res.pins
			for pin in res.pins
				saveLocal(pin)
		else
			cb new Error(res.message)

ajax =
	x: ()->
		if typeof XMLHttpRequest isnt "undefined"
			return new XMLHttpRequest()
		versions = [
			"MSXML2.XmlHttp.5.0"
			"MSXML2.XmlHttp.4.0"
			"MSXML2.XmlHttp.3.0"
			"MSXML2.XmlHttp.2.0"
			"Microsoft.XmlHttp"
		]
		for version in versions
			try
				xhr = new ActiveXObject(version)
				break
			catch e
			#			console.dir e
		return xhr
	send: (url, cb, method, data, sync)->
		x = ajax.x()
		x.open(method, url, sync)
		x.onreadystatechange = ()->
			if x.readyState is 4
				try
					cb JSON.parse(x.responseText)
					return
				catch e

				cb x.responseText

		if method is "POST"
			x.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

		x.send(data)
	get: (url, data, cb, sync)->
		query = []
		for key,value of data
			query.push "#{encodeURIComponent(key)}=#{encodeURIComponent(value)}"
		ajax.send url + "?" + query.join('&'), cb, 'GET', null, sync
	post: (url, data, cb, sync)->
		query = []
		for key,value of data
			query.push "#{encodeURIComponent(key)}=#{encodeURIComponent(value)}"
		ajax.send url, cb, 'POST', query.join('&'), sync