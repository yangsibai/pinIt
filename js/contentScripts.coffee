chrome.runtime.onMessage.addListener (request, sender, sendResponse)->
#	sendResponse(handleRequest(request.args))
	path = chrome.extension.getURL('/imgs/logo/20.png')
	cursorURL = "url('#{path}'),auto"
	$("body").css('cursor', cursorURL).mouseup(handleMouseEvent).bind('contextmenu.pageMark', handleContextMenu)

	unless $("#page-mark-modal").length
		modal = $("<div id='page-mark-modal'/>")
		$('body').append(modal)

handleRequest = (args) ->
	return args

handleMouseEvent = (event)->
	container = $('.page-mark')

	if container.is(event.target) or (container.has(event.target).length > 0)
		return

	if event.which is 1
		$('.page-mark .description').remove()
		pinURL = chrome.extension.getURL('/imgs/logo/32.png')

		positionX = event.pageX - 6
		positionY = event.pageY - 6

		pin = """
			<div class='pin page-mark' style='left:#{positionX}px;top:#{positionY}px'>
				<img src='#{pinURL}'/>
				<div class='description'>
					<textarea class='input'></textarea>
					<button class='submit'>Submit</button>
				</div>
			</div>
			"""
		if $('#page-mark-pin-collection').length
			$('#page-mark-pin-collection').append(pin)
		else
			pinCollection = $("<div/>").attr('id', 'page-mark-pin-collection').append(pin)
			$('body').append(pinCollection)
		sendDataToBackground
			x: positionX
			y: positionY
		$('.page-mark .input').focus()
		$('.page-mark .submit').click ()->
			text = $(this).siblings('.input').val()
			sendDataToBackground
				x: positionX
				y: positionY
				text: text

			$(this).parent().parent().append("<p class='message'>#{text}</p>")
			$(this).parent().remove()
	else
		if $("#page-mark-modal").length
			$('#page-mark-modal').remove()
		$("body").css('cursor', "default").unbind('mouseup');
		setTimeout ()->
			$("body").unbind('contextmenu.pageMark')
		, 1

handleContextMenu = (e)->
	false

sendDataToBackground = (data)->
	chrome.runtime.sendMessage data