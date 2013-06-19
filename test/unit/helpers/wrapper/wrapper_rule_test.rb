# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "wrapperruletest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require 'wl_tool'
Conf.db['database'] = "wp_wrapperruletest"
Conf.peer['peer']['program']['query_sample'] = 'test/config/sample_wtho_var.yml'
Conf.peer['peer']['program']['file_path'] = 'test/config/bootstrap_for_wrapper_rule_test.wl'
require 'test/unit'
require './lib/wl_setup'

# load bootstrap_for_test.wl as specified in the conf file peer.yml
class WrapperRuleTest < Test::Unit::TestCase
  
  def test_describedrule
    # init
    WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
    require 'test_helper'
    db = WLDatabase.setup_database_server
    assert_not_nil db
    helper = EngineHelper::WLHELPER
    helper.run_engine
    engine = EngineHelper::WLENGINE
    engine.load_bootstrap_fact
    db.save_facts_for_meta_data
    assert_not_nil db

    # test
    klassperson, relname, sch, instruction = db.create_model("persontest", {"id"=> "string", "name"=>"string"}, {wdl: true})
    assert_not_nil klassperson
    assert_equal "persontest_at_wrapperruletest", klassperson.wdl_table_name
    klassfriend, relname, sch, instruction = db.create_model("familytest", {"id"=> "string", "name"=>"string"}, {wdl: true})
    assert_not_nil klassfriend
    assert_equal "familytest_at_wrapperruletest", klassfriend.wdl_table_name
    DescribedRule.new(
      description: "first rule",
      wdlrule: "rule persontest@local($id,$name) :- familytest@local($id,$name);",
      role: "rule" ).save
    # check wrappers binding
    assert_equal [["comment_at_wrapperruletest", "Comment"],
      ["contact_at_wrapperruletest", "Contact"],
      ["describedrule_at_wrapperruletest", "DescribedRule"],
      ["familytest_at_wrapperruletest", "Familytest"],
      ["friend_at_wrapperruletest", "Friend"],
      ["persontest_at_wrapperruletest", "Persontest"],
      ["picture_at_wrapperruletest", "Picture"],
      ["picturelocation_at_wrapperruletest", "PictureLocation"],
      ["query1_at_wrapperruletest", "Query1"],
      ["query3_at_wrapperruletest", "Query3"],
      ["rating_at_wrapperruletest", "Rating"]], helper.wdl_tables_binding.sort    

    # Engine should have the right list of rules
    assert_equal({1=>
        "rule contact_at_wrapperruletest($username, $ip, $port, $online, $email) :- contact_at_sigmod_peer($username, $ip, $port, $online, $email);",
      2=>
        "rule comment_at_wrapperruletest(\" \", $ip, $port, \" \") :- contact_at_wrapperruletest($username, $ip, $port, $online, $email);",
      3=>
        "rule query1_at_wrapperruletest($title) :- picture_at_wrapperruletest($title, $_, $_, $_);",
      4=>
        "rule query3_at_wrapperruletest($title, $contact, $id, $image_url) :- picture_at_wrapperruletest($title, $contact, $id, $image_url), rating_at_sigmod_peer($id, 5);",
      5=>
        "rule deleg_from_wrapperruletest_4_1_at_sigmod_peer($title, $contact, $id, $image_url) :- picture_at_wrapperruletest($title, $contact, $id, $image_url);",
      6=>
        "rule friend_at_wrapperruletest($name, commenters) :- picture_at_wrapperruletest($_, $_, $id, $_), comment_at_wrapperruletest($id, $name, $_, $_);",
      7=>
        "rule persontest_at_wrapperruletest($id, $name) :- familytest_at_wrapperruletest($id, $name);"}, engine.snapshot_rules)

    # DescribedRule should contains collections and facts
    # FIXME comment :- contact ie. rule 2 is not in dexcribed rule
    assert_equal([[1,
          "Get all the titles for my pictures",
          "collection ext per query1@wrapperruletest(title*);",
          "extensional"],
        [2,
          "Get all the titles for my pictures",
          "rule query1@wrapperruletest($title) :- picture@wrapperruletest($title, $_, $_, $_);",
          "rule"],
        [3,
          "Get all my pictures with rating of 5",
          "collection ext per query3@wrapperruletest(title*);",
          "extensional"],
        [4,
          "Get all my pictures with rating of 5",
          "rule deleg_from_wrapperruletest_4_1@sigmod_peer($title, $contact, $id, $image_url) :- picture@wrapperruletest($title, $contact, $id, $image_url);",
          "rule"],
        [5,
          "Create a friends relations and insert all contacts who commented on one of my pictures. Finally include myself.",
          "collection ext per friend@wrapperruletest(name*);",
          "extensional"],
        [6,
          "Create a friends relations and insert all contacts who commented on one of my pictures. Finally include myself.",
          "rule friend@wrapperruletest($name, commenters) :- picture@wrapperruletest($_, $_, $id, $_), comment@wrapperruletest($id, $name, $_, $_);",
          "rule"],
        [7,
          "first rule",
          "rule persontest@wrapperruletest($id, $name) :- familytest@wrapperruletest($id, $name);",
          "rule"]],
      DescribedRule.all.map { |tup| [tup[:id], tup[:description], tup[:wdlrule], tup[:role] ] })
  end
end
