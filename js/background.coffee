serverAddress = "http://api.sibo.me"

chrome.browserAction.onClicked.addListener (tab)->
	if tab
		getRemotePin tab.url, (err, pins)->
			if err
				alert(err.message)
			else
				chrome.tabs.sendMessage tab.id,
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
	ajax.get "#{serverAddress}/pinIt/countOnPage",
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
	ajax.post "#{serverAddress}/pinIt/new", data, (res)->
		if res.code isnt 0
			alert(res.message)

###
    get pin from remote server
###
getRemotePin = (url, cb)->
	ajax.get "#{serverAddress}/pinIt/pinOnPage", {
		url: url
	}, (res)->
		if res.code is 0
			cb null, res.pins
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