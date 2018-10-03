/**
 * Show monitoring for GridFW apps
 */
/**
 * Configure Route monitoring
 */
var CONFIGURE_STEPS, DISABLE_STEPS;

CONFIGURE_STEPS = [
  // Configure route monitoring
  function(monit,
  app,
  options) {
    var _handle;
    _handle = monit._handle = app.handle;
    return app.handle = async function(req,
  ctx) {
      var d,
  processTime;
      d = Date.now();
      ctx.debug('MONIT-ROUTE',
  `Call ${req.method} ${req.url}`);
      await _handle.call(this,
  req,
  ctx);
      processTime = Date.now() - d;
      ctx.debug('MONIT-ROUTE',
  `Finished ${ctx.statusCode} ${ctx.contentLength || 0}bytes [ ${processTime}ms ] ${req.method} ${req.url}`);
    };
  }
];

DISABLE_STEPS = [
  // Stop route monitoring
  function(monit,
  app,
  options) {
    if (monit._handle) {
      app.handle = monit._handle;
    }
  }
];

module.exports = function(_options) {
  var _app, _enable;
  // flags
  _enable = false;
  _app = null;
  return {
    // return object
    // check gridfw min version
    name: 'GridFW-monitor',
    GridFWVersion: '0.x.x',
    // prepare plugin
    init: function(app) {
      _app = app;
      return this;
    },
    // configure
    configure: async function(options) {
      if (options) {
        _options = options;
        if (_enabled) {
          await this.disable();
          await this.enable();
        }
      }
    },
    // enable plugin
    enable: async function() {
      var _enabled, i, len, step;
      if (!_enabled) {
        _enabled = true;
// config
        for (i = 0, len = CONFIGURE_STEPS.length; i < len; i++) {
          step = CONFIGURE_STEPS[i];
          await step(this, this._app, _options);
        }
      }
    },
    // disable plugin
    disable: async function() {
      var _enabled, i, len, step;
      if (_enabled) {
        _enabled = false;
// config
        for (i = 0, len = DISABLE_STEPS.length; i < len; i++) {
          step = DISABLE_STEPS[i];
          await step(this, this._app, _options);
        }
      }
    }
  };
};
