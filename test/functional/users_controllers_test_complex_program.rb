# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "test_username"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_setup'
WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
Conf.peer['peer']['program']['file_path'] = 'app/assets/wlprogram/custom_bootstrap_program.wl'
require 'test_helper'

class UsersControllersTestComplexProgram < ActionController::TestCase
  tests UsersController

  test "1index" do
    get(:index)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:user_session)
  end

  test "2create" do    
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

    assert_equal ["comment_at_test_username",
      "contact_at_test_username",
      "describedrule_at_test_username",
      "friend_at_test_username",
      "person_at_test_username",
      "picture_at_test_username",
      "picturelocation_at_test_username",
      "rating_at_test_username"], engine.wl_program.wlcollections.keys.sort

    assert_equal [:chan,
      :comment_at_test_username,
      :contact_at_test_username,
      :describedrule_at_test_username,
      :friend_at_test_username,
      :person_at_test_username,
      :picture_at_test_username,
      :picturelocation_at_test_username,
      :rating_at_test_username,
      :sbuffer], engine.app_tables.map { |item| item.tabname }.sort

  end
end
