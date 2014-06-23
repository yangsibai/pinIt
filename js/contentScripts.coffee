chrome.runtime.onMessage.addListener (request, sender, sendResponse)->
#	sendResponse(handleRequest(request.args))
	path = chrome.extension.getURL('/imgs/logo/20.png')
	cursorURL = "url('#{path}'),auto"
	$("body").css('cursor', cursorURL).mouseup(handleMouseEvent).bind('contextmenu.pageMark', handleContextMenu)

handleRequest = (args) ->
	return args

handleMouseEvent = (event)->
	if event.which is 1
		pinURL = chrome.extension.getURL('/imgs/logo/32.png')
		pin = """
			<div style='position: absolute;left:#{event.pageX-6}px;top:#{event.pageY-6}px'>
			<img src='#{pinURL}'/>
			</div>
			"""
		if $('#page-mark-pin-collection').length
			$('#page-mark-pin-collection').append(pin)
		else
			pinCollection = $("<div></div>").attr('id', 'page-mark-pin-collection').append(pin)
			$('body').append(pinCollection)
	else
		$("body").css('cursor', "default").unbind('mouseup');
		setTimeout ()->
			$("body").unbind('contextmenu.pageMark')
		, 1

handleContextMenu = (e)->
	false