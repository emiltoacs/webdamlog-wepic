# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "test_username"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_setup'
WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
Conf.peer['peer']['program']['file_path'] = 'test/config/custom_bootstrap_program.wl'
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
      "deleg_from_test_username_5_1_at_sigmod_peer",
      "describedrule_at_test_username",
      "friend_at_test_username",
      "friend_example_at_test_username",
      "person_example_at_test_username",
      "picture_at_test_username",
      "picturelocation_at_test_username",
      "query1_at_test_username",
      "query2_at_test_username",
      "query3_at_test_username",
      "rating_at_test_username"], engine.wl_program.wlcollections.keys.sort

    assert_equal [:chan,
      :comment_at_test_username,
      :contact_at_test_username,
      :deleg_from_test_username_5_1_at_sigmod_peer,
      :describedrule_at_test_username,
      :friend_at_test_username,
      :friend_example_at_test_username,
      :person_example_at_test_username,
      :picture_at_test_username,
      :picturelocation_at_test_username,
      :query1_at_test_username,
      :query2_at_test_username,
      :query3_at_test_username,
      :rating_at_test_username,
      :sbuffer], engine.app_tables.map { |item| item.tabname }.sort

    # FIXME remove field such as wdl_rule_id that changes at each exec
    assert_equal [[],
      [],
      [["Jules",
          "localhost:4100",
          "false",
          "jules.testard@mail.mcgill.ca",
          "Jules Testard"],
        ["Julia", "localhost:4100", "false", "stoyanovich@drexel.edu", "jstoy"]],
      [["collection ext per query1@test_username(title*);",
          "Get all the titles for my pictures",
          "collection",
          93219420],
        ["rule query1@test_username($title) :- picture@test_username($title, $_, $_, $_);",
          "Get all the titles for my pictures",
          "collection",
          3]],
      [["12345", "12346"], ["12346", "12347"]],
      [["12345", "12346"],
        ["12345", "oscar"],
        ["12346", "12347"],
        ["12346", "hugo"],
        ["12347", "kendrick"]],
      [["me",
          "Jules",
          "12349",
          "http://www.cs.mcgill.ca/~jtesta/images/profile.png"],
        ["me", "Julia", "12350", "http://www.cs.columbia.edu/~jds1/pic_7.jpg"],
        ["me", "Julia", "12351", "http://www.cs.tau.ac.il/workshop/modas/julia.png"],
        ["sigmod",
          "Jules",
          "12345",
          "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"],
        ["sigmod",
          "Julia",
          "12346",
          "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"],
        ["sigmod",
          "local",
          "12347",
          "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"],
        ["webdam",
          "local",
          "12348",
          "http://www.cs.tau.ac.il/workshop/modas/webdam3.png"]],
      [],
      [["me"], ["sigmod"], ["webdam"]],
      [],
      []],
      engine.app_tables.map { |item| item.tabname }.sort.map{ |at|
      engine.tables[at].to_a.sort.map { |item| item.tap {|hs| hs.delete(:wdl_rule_id) } } }    

    assert_equal [
      "contact_at_test_username($username, $peerlocation, $online, $email, $facebook) :- contact_at_sigmod_peer($username, $peerlocation, $online, $email, $facebook)",
      "person_at_test_username($id, $name) :- friend_at_test_username($id, $name)",
      nil],
      engine.wl_program.rule_mapping.values.map{ |rules| rules.first.show_wdl_format if rules.first.is_a? WLBud::WLRule }

    
  end
end
