# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "test_username"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_setup'
WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
Conf.peer['peer']['program']['file_path'] = 'test/config/custom_bootstrap_program.wl'
require './test/test_helper'

class UserControllersTestDelayFactLoading < ActionController::TestCase
  tests UsersController

  test "2create" do
    
    db = WLDatabase.setup_database_server
    assert_not_nil db
    engine = EngineHelper::WLENGINE
    assert_not_nil engine

    # check everything is loaded but the facts
    assert_equal({"test_username"=>"127.0.0.1:#{engine.port}", "sigmod_peer"=>"localhost:4100"}, engine.wl_program.wlpeers)
    assert_equal(["picture_at_test_username",
        "picturelocation_at_test_username",
        "rating_at_test_username",
        "comment_at_test_username",
        "contact_at_test_username",
        "describedrule_at_test_username",
        "person_example_at_test_username",
        "friend_example_at_test_username"],
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
      :describedrule_at_test_username,
      :person_example_at_test_username,
      :friend_example_at_test_username], engine.tables.values.map { |coll| coll.tabname }
    assert_equal [], engine.tables[:picture_at_test_username].to_a.sort
    assert_equal [], engine.tables[:picturelocation_at_test_username].to_a.sort
    assert_equal [], engine.tables[:comment_at_test_username].to_a.sort
    assert_equal [], engine.tables[:contact_at_test_username].to_a.sort
    assert_equal [], engine.tables[:describedrule_at_test_username].to_a.sort
    assert_equal [], engine.tables[:person_at_test_username].to_a.sort
    assert_equal [], engine.tables[:friend_at_test_username].to_a.sort
    assert_equal ["rule contact_at_test_username($username, $peerlocation, $online, $email) :- contact_at_sigmod_peer($username, $peerlocation, $online, $email);",
      "rule person_example_at_test_username($id, $name) :- friend_example_at_test_username($id, $name);",
      "rule contact@local($username, $peerlocation, $online, $email):-contact@sigmod_peer($username, $peerlocation, $online, $email);"],
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
    
    assert_equal(Picture.all.empty?,false)
    # assert_equal(Rating.all.empty?,false)
    assert_equal(PictureLocation.all.empty?,false)
    assert_equal(DescribedRule.all.empty?,false)
    assert_equal(Picture.all.empty?,false)
    
    puts DescribedRule.all.inspect

    # check facts has been loaded in wdl
    # assert_equal [:localtick,
      # :stdio,
      # :halt,
      # :periodics_tbl,
      # :t_cycle,
      # :t_depends,
      # :t_provides,
      # :t_rules,
      # :t_stratum,
      # :t_table_info,
      # :t_table_schema,
      # :t_underspecified,
      # :t_derivation,
      # :chan,
      # :sbuffer,
      # :picture_at_test_username,
      # :picturelocation_at_test_username,
      # :rating_at_test_username,
      # :comment_at_test_username,
      # :contact_at_test_username,
      # :describedrule_at_test_username,
      # :person_example_at_test_username,
      # :friend_example_at_test_username,
      # :query1_at_test_username,
      # :query2_at_test_username,
      # :query3_at_test_username,
      # :deleg_from_test_username_5_1_at_sigmod_peer,
      # :friend_at_test_username], engine.tables.values.map { |coll| coll.tabname }
    # FIXME remove field such as wdl_rule_id that changes at each exec
    # assert_equal [["collection ext per friend@test_username(name*);",
        # "Create a friends relations and insert all contacts who commented on one of my pictures. Finally include myself.",
        # "collection",
        # 95631990],
      # ["collection ext per query1@test_username(title*);",
        # "Get all the titles for my pictures",
        # "collection",
        # 94619500],
      # ["collection ext per query2@test_username(title*);",
        # "Get all pictures from all my friends",
        # "collection",
        # 96505140],
      # ["collection ext per query3@test_username(title*);",
        # "Get all my pictures with rating of 5",
        # "collection",
        # 98370180],
      # ["rule deleg_from_test_username_5_1@sigmod_peer($title, $contact, $id, $image_url) :- picture@test_username($title, $contact, $id, $image_url);",
        # "Get all my pictures with rating of 5",
        # "collection",
        # 6],
      # ["rule query1@test_username($title) :- picture@test_username($title, $_, $_, $_);",
        # "Get all the titles for my pictures",
        # "collection",
        # 3]], engine.tables[:picture_at_test_username].to_a.sort.map { |t| t.to_a }
    # assert_equal [], engine.tables[:picturelocation_at_test_username].to_a.sort.map { |t| t.to_a }
    # assert_equal [], engine.tables[:comment_at_test_username].to_a.sort.map { |t| t.to_a }
    # assert_equal [["Jules",
        # "localhost:4100",
        # "false",
        # "jules.testard@mail.mcgill.ca",
        # "Jules Testard"],
      # ["Julia", "localhost:4100", "false", "stoyanovich@drexel.edu", "jstoy"]],
      # engine.tables[:contact_at_test_username].to_a.sort.map { |t| t.to_a }
    # assert_equal [["collection ext persistent friends@local(name*,group*);\nrule friends@local($name,commenters):- pictures@local($_,$_,$id,$_),comments@local($id,$name,$_,$_);\n",
        # "Create a friends relations and insert all contacts who commented on one of my pictures. Finally include myself."],
      # ["collection int query1@local(title*);\nrule query1@local($title):-pictures@local($title,$_,$_,$_);\n",
        # "Get all the titles for my pictures"],
      # ["collection int query2@local(title*,contact*,id*,image_url*);\nrule query2@local($title, $contact, $id, $image_url):- contact@local($contact, $_, $_, $_, $_),pictures@$contact($title, $contact, $id, $image_url);\n",
        # "Get all pictures from all my friends"],
      # ["collection int query3@local(title*,contact*,id*,image_url*);\nrule query3@local($title,$contact,$id,$image_url):- pictures@local($title,$contact,$id,$image_url),rating@sigmod_peer($id,5);\n",
        # "Get all my pictures with rating of 5"],
      # ["rule pictures@contact($title, $contact, $id, $image_url):- friends@local(contact,$group),friends@local($peer,$group),pictures@$peer($title,$contact,$id,$image_url),picturelocation@$peer($id,\"given location\");    \n",
        # "Send to contact all pictures taken last week by our common friends and me at a given location"]],
      # engine.tables[:describedrule_at_test_username].to_a.sort.map { |t| t.to_a }
    # assert_equal [["12345", "12346"],
      # ["12345", "oscar"],
      # ["12346", "12347"],
      # ["12346", "hugo"],
      # ["12347", "kendrick"]], engine.tables[:person_at_test_username].to_a.sort.map { |t| t.to_a }
    # assert_equal [["12345", "12346"], ["12346", "12347"]],
      # engine.tables[:friend_at_test_username].to_a.sort.map { |t| t.to_a }
# 
    # # check facts has been loaded in wepic models
    # assert_equal ["rule contact_at_test_username($username, $peerlocation, $online, $email, $facebook) :- contact_at_sigmod_peer($username, $peerlocation, $online, $email, $facebook);",
      # "rule person_example_at_test_username($id, $name) :- friend_example_at_test_username($id, $name);",
      # "rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);"],
      # Contact.all.map { |ar| [ ar[:username], ar[:peerlocation], ar[:online], ar[:email], ar[:facebook] ] }
  end
end