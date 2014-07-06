pagePin = []
draging = false
ele = null

chrome.runtime.onMessage.addListener (request, sender, sendResponse)->
	if request.pins and request.pins.length > 0
		for pin in request.pins
			pinOnPage(pin.x, pin.y, pin.text)

	console.log("开始添加");
	path = chrome.extension.getURL('/imgs/logo/20.png')
	cursorURL = "url('#{path}'),auto"
	$("body").css('cursor', cursorURL).mouseup(handleMouseUp).bind('contextmenu.pageMark', handleContextMenu)

	unless $("#page-mark-modal").length
		modal = $("<div id='page-mark-modal'/>")
		$('body').append(modal)

handleRequest = (args) ->
	return args

handleMouseUp = (event)->
	draging = false
	container = $('.page-mark')

	if container.is(event.target) or (container.has(event.target).length > 0)
		return

	if event.which is 1
		$('.page-mark .description').remove()
		positionX = event.pageX - 6
		positionY = event.pageY - 6

		pinOnPage(positionX, positionY, '')

		sendDataToBackground
			width: $(window).width()
			height: $(window).height()
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
		$(".page-mark .description").remove()
		$("body").css('cursor', "default").unbind('mouseup');
		setTimeout ()->
			$("body").unbind('contextmenu.pageMark')
		, 1

pinOnPage = (positionX, positionY, text)->
	found = false
	for hasPin in pagePin
		if hasPin.x is positionX and hasPin.y is positionY
			found = true

	unless found
		pinURL = chrome.extension.getURL('/imgs/logo/32.png')
		pin = """
				<div class='pin page-mark' style='left:#{positionX}px;top:#{positionY}px'>
					<img src='#{pinURL}'/>
				</div>
				"""
		if $('#page-mark-pin-collection').length
			$('#page-mark-pin-collection').append(pin)
		else
			pinCollection = $("<div/>").attr('id', 'page-mark-pin-collection').append(pin)
			$('body').append(pinCollection)

#		$("#page-mark-pin-collection .pin")
#		.unbind('mousedown', mouseDown)
#		.bind("mousedown", mouseDown)
#
#		$("body")
#		.unbind("mousemove", mouseMove)
#		.unbind("mouseup", mouseUp)
#		.bind("mousemove", mouseMove)
#		.bind("mouseup", mouseUp)

mouseDown = (e)->
	draging = true
	ele = $(this)

mouseMove = (e)->
	if draging && ele
		ele.css("left", e.pageX).css("top", e.pageY)

mouseUp = (e)->
	console.log "mouse up"
	draging = false
	ele = null

handleContextMenu = (e)->
	false

sendDataToBackground = (data)->
	chrome.runtime.sendMessage
		data: data