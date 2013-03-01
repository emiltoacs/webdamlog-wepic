ENV["USERNAME"] = "test_peer"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_setup'
WLSetup.setup_storage(Conf.manager?, Conf.db)
require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  tests UsersController

  test "index" do
    get(:index)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:user_session)
  end

  test "create" do
    post(:create,
      :user=>{
        :username => "test_username",
        :email => "test_user_email",
        :password => "test_user_password",
        :password_confirmation => "test_user_password"
      })
    assert_not_nil assigns(:user)
    assert !(assigns(:user).new_record?), "@user should have been saved in the db"
    #p assigns(:user).methods
    #assert !(assigns(:user).new?)
    assert_response(200)  
    assert_not_nil @response.body
    
    # EngineHelper::WLENGINE    
    # assert_redirected_to(:controller => "wepic")
    # assert_redirected_to(page_url(:title => 'wepic'))    
  end

end