# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "test_username"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_setup'
WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
Conf.peer['peer']['program']['file_path'] = 'test/config/bootstrap_for_loading_delay_fact.wl'
require './test/test_helper'

class UserControllersTestDelayFactLoading < ActionController::TestCase
  tests UsersController

  test "2create" do    
    engine = EngineHelper::WLENGINE
    assert_not_nil engine
    
    # check everything is loaded but the facts
    assert_equal({"test_username"=>"127.0.0.1:#{engine.port}", "sigmod_peer"=>"localhost:4100"}, engine.wl_program.wlpeers)
    assert_equal(["picture_at_test_username",
        "picturelocation_at_test_username",
        "rating_at_test_username",
        "comment_at_test_username",
        "contact_at_test_username",
        "describedrule_at_test_username"],
      engine.wl_program.wlcollections.keys)
    assert_equal [:localtick,
      :stdio,
      :halt,
      :periodics_tbl,
      :t_cycle,
      :t_depends,
      :t_provides,
      :t_rules,
      :t_stratum,
      :t_table_info,
      :t_table_schema,
      :t_underspecified,
      :t_derivation,
      :chan,
      :sbuffer,
      :picture_at_test_username,
      :picturelocation_at_test_username,
      :rating_at_test_username,
      :comment_at_test_username,
      :contact_at_test_username,
      :describedrule_at_test_username], engine.tables.values.map { |coll| coll.tabname }
    assert_equal [], engine.tables[:picture_at_test_username].to_a.sort
    assert_equal [], engine.tables[:picturelocation_at_test_username].to_a.sort
    assert_equal [], engine.tables[:comment_at_test_username].to_a.sort
    assert_equal [], engine.tables[:contact_at_test_username].to_a.sort
    assert_equal [], engine.tables[:describedrule_at_test_username].to_a.sort
    assert_equal [], engine.tables[:person_at_test_username].to_a.sort
    assert_equal [], engine.tables[:friend_at_test_username].to_a.sort
    assert_equal ["rule contact_at_test_username($username, $ip, $port, $online, $email) :- contact_at_sigmod_peer($username, $ip, $port, $online, $email);",
      "rule contact_at_test_username($username, $ip, $port, $online, $email) :- contact_at_sigmod_peer($username, $ip, $port, $online, $email);"],
      engine.wl_program.rule_mapping.values.map{ |rules| rules.first.is_a?(WLBud::WLRule) ? rules.first.show_wdl_format : rules.first }
    
    # start engine
    post(:create,
      :user=>{
        :username => "test_username",
        :email => "test_user_email@emailprovider.dom",
        :password => "test_user_password",
        :password_confirmation => "test_user_password"
      })
    assert_not_nil assigns(:user)
    assert engine.running_async
    assert_kind_of WLRunner, engine

    # check facts has been loaded in wdl
    assert_equal [:localtick,
      :stdio,
      :halt,
      :periodics_tbl,
      :t_cycle,
      :t_depends,
      :t_provides,
      :t_rules,
      :t_stratum,
      :t_table_info,
      :t_table_schema,
      :t_underspecified,
      :t_derivation,
      :chan,
      :sbuffer,
      :picture_at_test_username,
      :picturelocation_at_test_username,
      :rating_at_test_username,
      :comment_at_test_username,
      :contact_at_test_username,
      :describedrule_at_test_username,
      :query1_at_test_username,
      :query2_at_test_username,
      :query3_at_test_username,
      :deleg_from_test_username_4_1_at_sigmod_peer,
      :friend_at_test_username], engine.tables.values.map { |coll| coll.tabname }
    
    # tables
    array = engine.tables[:picture_at_test_username].map{ |t| Hash[t.each_pair.to_a] }
    assert_equal [{:title=>"sigmod",
        :owner=>"test_username",
        :_id=>"12347",
        :url=>
          "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"},
      {:title=>"webdam",
        :owner=>"test_username",
        :_id=>"12348",
        :url=>"http://www.cs.tau.ac.il/workshop/modas/webdam3.png"}], array
    array = engine.tables[:picturelocation_at_test_username].map{ |t| Hash[t.each_pair.to_a] }
    assert_equal [{:_id=>"12347", :location=>"Columbia"},
      {:_id=>"12348", :location=>"Tau workshop"}], array
    array = engine.tables[:comment_at_test_username].map{ |t| Hash[t.each_pair.to_a] }
    array.each{ |h| h.delete :date }
    assert_equal [], array
    array = engine.tables[:describedrule_at_test_username].map{ |t| Hash[t.each_pair.to_a] }
    array.each { |t| assert_not_nil t[:wdl_rule_id] }
    array.each { |h| h.delete :wdl_rule_id }
    assert_equal [{:wdlrule=>"collection ext per query1@test_username(title*);",
        :description=>"Get all the titles for my pictures",
        :role=>"extensional"},
      {:wdlrule=>
          "rule query1@test_username($title) :- picture@test_username($title, $_, $_, $_);",
        :description=>"Get all the titles for my pictures",
        :role=>"rule"},
      {:wdlrule=>
          "collection ext per query2@test_username(title*,contact*,id*,url*);",
        :description=>"Get all pictures from all my friend",
        :role=>"extensional"},
      {:wdlrule=>
          "collection ext per query3@test_username(title*,contact*,id*,url*);",
        :description=>"Get all my pictures with rating of 5",
        :role=>"extensional"},
      {:wdlrule=>
          "rule deleg_from_test_username_4_1@sigmod_peer($title, $contact, $id, $url) :- picture@test_username($title, $contact, $id, $url);",
        :description=>"Get all my pictures with rating of 5",
        :role=>"rule"},
      {:wdlrule=>"collection ext per friend@test_username(name*,usergroup*);",
        :description=>
          "Create a friend relations and insert all contacts who commented on one of my pictures. Finally include myself.",
        :role=>"extensional"},
      {:wdlrule=>
          "rule friend@test_username($name, commenters) :- picture@test_username($_, $_, $id, $_), comment@test_username($id, $name, $_, $_);",
        :description=>
          "Create a friend relations and insert all contacts who commented on one of my pictures. Finally include myself.",
        :role=>"rule"}], array
    array = engine.tables[:contact_at_test_username].map{ |t| Hash[t.each_pair.to_a] }
    array.each { |t| assert_not_nil t[:port] }
    array.each { |h| h.delete :port }
    assert_equal [{:username=>"test_username",
        :ip=>"127.0.0.1",
        :online=>"true",
        :email=>"none"}], array

    # check facts has been loaded in wepic models
    assert_equal [["test_username", "127.0.0.1", true, "none"]],
      Contact.all.map { |ar| [ ar[:username], ar[:ip], ar[:online], ar[:email] ] }
    assert_equal [["\ncollection ext persistent picture@local(title*, owner*, _id*, url*);",
        "bootstrap",
        "unknown"],
      ["\ncollection ext persistent rating@local(_id*, rating*, owner*);",
        "bootstrap",
        "unknown"],
      ["\ncollection ext persistent comment@local(_id*,author*,text*,date*);",
        "bootstrap",
        "unknown"],
      ["\ncollection ext persistent contact@local(username*, ip*, port*, online*, email*);",
        "bootstrap",
        "unknown"],
      ["\ncollection ext persistent describedrule@local(wdlrule*, description*, role*, wdl_rule_id*);",
        "bootstrap",
        "unknown"],
      ["\nrule contact@local($username, $ip, $port, $online, $email):-contact@sigmod_peer($username, $ip, $port, $online, $email);",
        "bootstrap",
        "rule"],
      ["collection ext per query1@test_username(title*);",
        "Get all the titles for my pictures",
        "extensional"],
      ["rule query1@test_username($title) :- picture@test_username($title, $_, $_, $_);",
        "Get all the titles for my pictures",
        "rule"],
      ["collection ext per query2@test_username(title*);",
        "Get all pictures from all my friend",
        "extensional"],
      ["collection ext per query3@test_username(title*);",
        "Get all my pictures with rating of 5",
        "extensional"],
      ["rule deleg_from_test_username_4_1@sigmod_peer($title, $contact, $id, $url) :- picture@test_username($title, $contact, $id, $url);",
        "Get all my pictures with rating of 5",
        "rule"],
      ["collection ext per friend@test_username(name*);",
        "Create a friend relations and insert all contacts who commented on one of my pictures. Finally include myself.",
        "extensional"],
      ["rule friend@test_username($name, commenters) :- picture@test_username($_, $_, $id, $_), comment@test_username($id, $name, $_, $_);",
        "Create a friend relations and insert all contacts who commented on one of my pictures. Finally include myself.",
        "rule"]],
      DescribedRule.all.map { |ar| [ ar[:wdlrule], ar[:description], ar[:role] ] }
    assert_equal [["sigmod",
        "test_username",
        12347,
        "http://www.sigmod.org/about-sigmod/sigmod-logo/archive/800x256/sigmod.gif"],
      ["webdam",
        "test_username",
        12348,
        "http://www.cs.tau.ac.il/workshop/modas/webdam3.png"]],
      Picture.all.map { |ar| [ ar[:title], ar[:owner], ar[:_id], ar[:image_url] ] }
    
    # jules
    rule_a = "rule contact@local($username,$ip,$port, $online, $email):-contact@sigmod_peer($username,$ip,$port, $online, $email);"
    rule_b = "rule   contact@local($username,$ip,$port,$online,$email):-  contact@sigmod_peer($username,$ip  ,$port ,  $online,$email)\n;\n"
    assert_a = engine.parse(rule_a).first.show_wdl_format
    assert_b = engine.parse(rule_b).first.show_wdl_format
    assert_equal(assert_a,assert_b)
    # #The rule b is the same as one added to the program by default. This rule,
    # although syntactically correct, #should not pass.
    saved, err = ContentHelper::add_to_described_rules(rule_b,'should not work','rule')
    assert_equal(false,saved)
    # assert_not_nil(err[:exists])

    # FIXME : Should work but need bug fix in Webdamlog parser. rule_c = "rule contact@local(newcontact,localhost,10023,false,\"newcontact@gmail.com\"):-;"
    # saved, err = ContentHelper::add_to_described_rules(rule_c,'should
    # work','rule') assert_equal(true,saved) puts err
    
    # Should be working but does not
    rule_d = "rule rating@local($id, 3, $owner):-picture@local(title, $owner, $id, url2);"
    saved, err = ContentHelper::add_to_described_rules(rule_d,'should work','rule')
    assert_equal(true,saved)
    saved, err = ContentHelper::add_to_described_rules(rule_d,'should not work','rule')
    assert_equal(false,saved)
    # assert_not_nil(err[:exists])
  end
    
end