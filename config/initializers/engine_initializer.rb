require 'engine_helper'

module EngineHelper

  WLSINGELTON = EngineHelper.instance
  WLENGINE = WLSINGELTON.engine
  WLLOGGER = WLSINGELTON.enginelogger

end