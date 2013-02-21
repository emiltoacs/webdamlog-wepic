class EngineController < ApplicationController
  include EngineHelper

  def index
    @engine = WLENGINE
  end
  
end