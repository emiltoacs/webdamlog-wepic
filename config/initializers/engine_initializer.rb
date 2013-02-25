require 'engine_helper'

module EngineHelper

  unless Conf.manager?
    WLHELPER = EngineHelper.instance
    WLENGINE = WLHELPER.engine
    WLLOGGER = WLHELPER.enginelogger
  end

end