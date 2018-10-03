###*
 * Show monitoring for GridFW apps
###

###*
 * Configure Route monitoring
###
CONFIGURE_STEPS=[
	# Configure route monitoring
	(monit, app, options)->
		_handle = monit._handle = app.handle
		app.handle = (req, ctx)->
			d= Date.now()
			ctx.debug 'MONIT-ROUTE', "Call #{req.method} #{req.url}"
			await _handle.call this, req, ctx
			processTime = Date.now() - d
			ctx.debug 'MONIT-ROUTE', "Finished #{ctx.statusCode} #{ctx.contentLength||0}bytes [ #{processTime}ms ] #{req.method} #{req.url}"
			return
];

### disable plugin steps ###
DISABLE_STEPS = [
	# Stop route monitoring
	(monit, app, options)->
		if monit._handle
			app.handle = monit._handle
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
		unless _enabled
			_enabled = on
			# config
			for step in CONFIGURE_STEPS
				await step this, @_app, _options
		return
	# disable plugin
	disable: ->
		if _enabled
			_enabled = off
			# config
			for step in DISABLE_STEPS
				await step this, @_app, _options
		return

	
