require 'webdamlog_wrapper/engine_helper'

module EngineHelper

  unless Conf.manager?
    # Instanciation of the engine helper a singleton class of EngineHelper
    # @!attribute [EngineHelper] the whole engine helper
    WLHELPER = EngineHelper.instance
    # Instantiation of the webdamlog engine as a WLRunner object
    # @!attribute [WLRunner] the engine itself
    WLENGINE = WLHELPER.engine
    # The logger to report messsages specific to webdamlog inherit from the
    # application logger WLLogger
    WLLOGGER = WLHELPER.enginelogger
  end

end