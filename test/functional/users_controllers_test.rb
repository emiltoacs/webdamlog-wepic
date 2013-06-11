# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
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
        :email => "test_user_email@emailprovider.dom",
        :password => "test_user_password",
        :password_confirmation => "test_user_password"
      })
    assert_not_nil assigns(:user)
    assert !(assigns(:user).new_record?), "@user should have been saved in the db"
    assert_response(302)
    assert_not_nil @response.body
    assert_redirected_to(:controller => "wepic")

    engine = EngineHelper::WLENGINE
    assert_not_nil engine
    assert engine.running_async
    assert_kind_of WLRunner, engine
    assert_equal([["sigmod_peer", "localhost:4100"], ["test_peer", "localhost:5100"]], engine.wl_program.wlpeers.sort)
    assert_equal 5, engine.wl_program.wlcollections.size
    assert_equal ["comment_at_test_peer",
      "contact_at_test_peer",
      "picture_at_test_peer",
      "picturelocation_at_test_peer",
      "rating_at_test_peer"], engine.wl_program.wlcollections.keys.sort
    
    assert_equal 2, engine.wl_program.rule_mapping.size
    assert_equal [1,
      "rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);"],
      engine.wl_program.rule_mapping.keys
  end

  test "add" do
    post(:create,
      :user=>{
        :username => "test_username",
        :email => "test_user_email@emailprovider.dom",
        :password => "test_user_password",
        :password_confirmation => "test_user_password"
      })
    assert_not_nil assigns(:user)
    assert_redirected_to(:controller => "wepic")
    engine = EngineHelper::WLENGINE
    assert_not_nil engine
    assert engine.running_async
  end
end