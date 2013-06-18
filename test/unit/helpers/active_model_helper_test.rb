# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "wrapperruletest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require 'wl_tool'
Conf.db['database']="wp_wrapperruletest"
require 'test/unit'
require './lib/wl_setup'
Conf.peer['peer']['program']['file_path'] = 'test/config/bootstrap_for_test_model_helper.wl'

# load bootstrap_for_test.wl as specified in the conf file peer.yml
class ActiveModelHelperTest < Test::Unit::TestCase
  def test_active_model    
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

    # test ActiveModelHelper
    am = ActiveModelHelper.create_active_model_class('UneRelation', {firstfield: Integer, secondfield: String})
    assert_not_nil am
    assert_equal "UneRelation", am.name

    # test ActiveModelWrappper
    am = ActiveModelHelper.create_active_model_class('friend', { username: String, ip: String, port: Integer, online: String, email: String })
    am.send :include, WrapperHelper::ActiveModelWrapper    
    am.bind_wdl_relation
    assert am.bound
    assert_not_nil am.engine
    assert_equal 'friend_at_wrapperruletest', am.wdl_tabname
    assert_not_nil am.engine.tables[:friend_at_wrapperruletest]
    assert_equal 3, am.all.size
    assert_equal am.engine.tables[:friend_at_wrapperruletest].map{ |t| t.values },
      am.all.map{ |tup| [tup[:username], tup[:ip], "#{tup[:port]}", tup[:online], tup[:email] ] }

    # test WrapperHelper::ActiveModelSaveWrapper
    # TODO

  end # def test_describedrule
end # class WrapperRuleTest



