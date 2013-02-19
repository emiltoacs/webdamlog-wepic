require 'webdamlog_engine'

WLSINGELTON = WebdamlogEngine::WebdamlogEngine.instance
WLENGINE = WLSINGELTON.engine
WLLOGGER = WLSINGELTON.enginelogger