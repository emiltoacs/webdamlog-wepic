require 'engine_helper'

module EngineHelper

  unless Conf.manager?
    # Instanciation of the engine helper
    WLHELPER = EngineHelper.instance
    # Instanciation of the wl engine
    WLENGINE = WLHELPER.engine
    # The logger to report messsages specific to webdamlog inherit from the
    # application logger WLLogger
    WLLOGGER = WLHELPER.enginelogger    
  end

end