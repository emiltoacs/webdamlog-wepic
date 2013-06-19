# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "test_username"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_setup'
WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
Conf.peer['peer']['program']['file_path'] = 'test/config/bootstrap_for_test_complex_program.wl'
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

    assert_equal [[],
      [],
      [{:username=>"Jules",
          :ip=>"127.0.0.1",
          :online=>"false",
          :email=>"jules.testard@mail.mcgill.ca"},
        {:username=>"Julia",
          :ip=>"127.0.0.1",
          :online=>"false",
          :email=>"stoyanovich@drexel.edu"},
        {:username=>"test_username",
          :ip=>"127.0.0.1",
          :online=>"true",
          :email=>"none"}],
      [],
      [{:wdlrule=>"collection ext per query1@test_username(title*);",
          :description=>"Get all the titles for my pictures",
          :role=>"extensional"},
        {:wdlrule=>
            "rule query1@test_username($title) :- picture@test_username($title, $_, $_, $_);",
          :description=>"Get all the titles for my pictures",
          :role=>"rule"},
        {:wdlrule=>"collection ext per query2@test_username(title*);",
          :description=>"Get all pictures from all my friend",
          :role=>"extensional"},
        {:wdlrule=>"collection ext per query3@test_username(title*);",
          :description=>"Get all my pictures with rating of 5",
          :role=>"extensional"},
        {:wdlrule=>
            "rule deleg_from_test_username_5_1@sigmod_peer($title, $contact, $id, $image_url) :- picture@test_username($title, $contact, $id, $image_url);",
          :description=>"Get all my pictures with rating of 5",
          :role=>"rule"},
        {:wdlrule=>"collection ext per friend@test_username(name*);",
          :description=>
            "Create a friend relations and insert all contacts who commented on one of my pictures. Finally include myself.",
          :role=>"extensional"},
        {:wdlrule=>
            "rule friend@test_username($name, commenters) :- picture@test_username($_, $_, $id, $_), comment@test_username($id, $name, $_, $_);",
          :description=>
            "Create a friend relations and insert all contacts who commented on one of my pictures. Finally include myself.",
          :role=>"rule"}],
      [],
      [{:_id1=>"12345", :_id2=>"12346"}, {:_id1=>"12346", :_id2=>"12347"}],
      [{:_id=>"12345", :name=>"oscar"},
        {:_id=>"12346", :name=>"hugo"},
        {:_id=>"12347", :name=>"kendrick"},
        {:_id=>"12345", :name=>"12346"},
        {:_id=>"12346", :name=>"12347"}],
      [{:title=>"sigmod",
          :owner=>"Jules",
          :_id=>"12345",
          :image_url=>
            "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"},
        {:title=>"sigmod",
          :owner=>"Julia",
          :_id=>"12346",
          :image_url=>
            "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"},
        {:title=>"sigmod",
          :owner=>"local",
          :_id=>"12347",
          :image_url=>
            "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"},
        {:title=>"webdam",
          :owner=>"local",
          :_id=>"12348",
          :image_url=>"http://www.cs.tau.ac.il/workshop/modas/webdam3.png"},
        {:title=>"me",
          :owner=>"Jules",
          :_id=>"12349",
          :image_url=>"http://www.cs.mcgill.ca/~jtesta/images/profile.png"},
        {:title=>"me",
          :owner=>"Julia",
          :_id=>"12350",
          :image_url=>"http://www.cs.columbia.edu/~jds1/pic_7.jpg"},
        {:title=>"me",
          :owner=>"Julia",
          :_id=>"12351",
          :image_url=>"http://www.cs.tau.ac.il/workshop/modas/julia.png"}],
      [{:_id=>"12345", :location=>"New York"},
        {:_id=>"12346", :location=>"New York"},
        {:_id=>"12347", :location=>"New York"},
        {:_id=>"12348", :location=>"Paris, France"},
        {:_id=>"12349", :location=>"McGill University"},
        {:_id=>"12350", :location=>"Columbia"},
        {:_id=>"12351", :location=>"Tau workshop"}],
      [{:title=>"sigmod"}, {:title=>"webdam"}, {:title=>"me"}],
      [],
      [],
      [],
      [{:dst=>"localhost:4100",
          :rel_name=>"deleg_from_test_username_5_1_at_sigmod_peer",
          :fact=>
            ["sigmod",
            "Jules",
            "12345",
            "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"]},
        {:dst=>"localhost:4100",
          :rel_name=>"deleg_from_test_username_5_1_at_sigmod_peer",
          :fact=>
            ["sigmod",
            "Julia",
            "12346",
            "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"]},
        {:dst=>"localhost:4100",
          :rel_name=>"deleg_from_test_username_5_1_at_sigmod_peer",
          :fact=>
            ["sigmod",
            "local",
            "12347",
            "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"]},
        {:dst=>"localhost:4100",
          :rel_name=>"deleg_from_test_username_5_1_at_sigmod_peer",
          :fact=>
            ["webdam",
            "local",
            "12348",
            "http://www.cs.tau.ac.il/workshop/modas/webdam3.png"]},
        {:dst=>"localhost:4100",
          :rel_name=>"deleg_from_test_username_5_1_at_sigmod_peer",
          :fact=>
            ["me",
            "Jules",
            "12349",
            "http://www.cs.mcgill.ca/~jtesta/images/profile.png"]},
        {:dst=>"localhost:4100",
          :rel_name=>"deleg_from_test_username_5_1_at_sigmod_peer",
          :fact=>
            ["me", "Julia", "12350", "http://www.cs.columbia.edu/~jds1/pic_7.jpg"]},
        {:dst=>"localhost:4100",
          :rel_name=>"deleg_from_test_username_5_1_at_sigmod_peer",
          :fact=>
            ["me",
            "Julia",
            "12351",
            "http://www.cs.tau.ac.il/workshop/modas/julia.png"]}]],
      engine.app_tables.map { |item| item.tabname }.sort.map { |at|
      engine.tables[at].map { |t|
        h = Hash[t.each_pair.to_a]
        h.delete(:wdl_rule_id)
        h.delete(:port)
        h
      }
    }
    # REMARK if you use do end with map it returns a enumerator rather than { } return an array as expected
      
    assert_equal [
      "contact_at_test_username($username, $peerlocation, $online, $email, $facebook) :- contact_at_sigmod_peer($username, $peerlocation, $online, $email, $facebook)",
      "person_at_test_username($id, $name) :- friend_at_test_username($id, $name)",
      nil],
      engine.wl_program.rule_mapping.values.map{ |rules| rules.first.show_wdl_format if rules.first.is_a? WLBud::WLRule }
  end
end
