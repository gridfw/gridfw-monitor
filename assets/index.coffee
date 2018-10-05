###*
 * Show monitoring for GridFW apps
###
GridFW = require '../../gridfw'
PROTO = GridFW.prototype
PROXY = Object.create PROTO
# define proxies
Object.defineProperties PROXY,
	# request handler
	handle: (req, ctx)->
		d= Date.now()
		ctx.debug 'MONIT-ROUTE', "Call #{req.method} #{req.url}"
		await PROTO.handle.call this, req, ctx
		processTime = Date.now() - d
		ctx.debug 'MONIT-ROUTE', "Finished #{ctx.statusCode} #{ctx.contentLength||0}bytes [ #{processTime}ms ] #{req.method} #{req.url}"
		return
	# send file
module.exports = (_options)->
	_app = null
	_prevProto= null
	# check gridfw min version
	name: 'GridFW-monitor'
	GridFWVersion: '0.x.x'
	init: (app)->
		_app = app
		# chain
		this
	# configure
	configure: (options)->
		if options
			_options = options
			if _enabled
				await @disable()
				await @enable()
		return
	# enable plugin
	enable: ->
		unless _prevProto
			throw new Error 'Not initialized' unless _app
			_prevProto = Object.getPrototypeOf _app
			Object.setPrototypeOf _app, PROXY
			if _app.isEnabled()
				await _app.reload()
		return
	# disable plugin
	disable: ->
		if _prevProto
			Object.setPrototypeOf _app, _prevProto
			if _app.isEnabled()
				await _app.reload()
		return





###*
 * Configure Route monitoring
###
CONFIGURE_STEPS=[
	# Configure route monitoring
	(monit, app, options)->
		unless monit._prevReqHandle
			# previous handler
			previousHandle = monit._prevReqHandle = app.handle
			# proxy
			app.handle = (req, ctx)->
				
			# apply
			server = app.server
			if server
				server.off 'request', previousHandle
				server.on 'request', app.handle
		return
];

### disable plugin steps ###
DISABLE_STEPS = [
	# Stop route monitoring
	(monit, app, options)->
		if monit._prevReqHandle
			currentH = app.handle
			prev = monit._prevReqHandle
			monit._prevReqHandle = null
			# apply
			app.handle = prev
			server = app.server
			if server
				server.off 'request', currentH
				server.on 'request', prev
		return

];


module.exports = (_options)->
	# flags
	_enable = off
	_app = null

	# return object
	# check gridfw min version
	name: 'GridFW-monitor'
	GridFWVersion: '0.x.x'
	# prepare plugin
	init: (app)->
		_app = app
		# chain
		this
	# configure
	configure: (options)->
		if options
			_options = options
			if _enabled
				await @disable()
				await @enable()
		return
	# enable plugin
	enable: ->
		console.log '----- enalble shit'
		unless _enabled
			console.log '----- enalble shiti'
			_enabled = on
			# config
			for step in CONFIGURE_STEPS
				await step this, _app, _options
		return
	# disable plugin
	disable: ->
		if _enabled
			_enabled = off
			# config
			for step in DISABLE_STEPS
				await step this, _app, _options
		return

	
