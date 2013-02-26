ENV["USERNAME"] = "test_peer"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_setup'
WLSetup.setup_storage(Conf.manager?, Conf.db)
require 'test_helper'

class EngineControllerTest < ActionController::TestCase
  tests EngineController

  test "index" do
    get(:index)
    assert_response :success
    assert_not_nil assigns(:engine)
  end
   
end
