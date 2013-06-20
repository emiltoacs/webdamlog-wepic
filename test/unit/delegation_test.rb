# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "databasemodeltest"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require 'wl_tool'
Conf.db['database']="wp_databasemodeltest"
require 'test/unit'
require './lib/wl_setup'

class DelegationTest < Test::Unit::TestCase

  def test_delegation
    
    # setup
    WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
    require 'test_helper'
    db = WLDatabase.setup_database_server
    assert_not_nil db
    helper = EngineHelper::WLHELPER
    helper.run_engine
    engine = EngineHelper::WLENGINE

    # test WLRunner method
    assert_equal({}, engine.flush_delegations)
    # simulate reception of delgation by sending via the own channel of the peer
    # to itself HACKY only for the tests
    engine.sync_do {
      engine.chan <~ [["localhost:#{helper.port}",
          ["p0", "0",
            {"rules"=>["rule local2@test_pending_delegation_content('14') :- local@test_pending_delegation_content('4');"],
              "facts"=>{},
              "declarations"=>[]
            }]]]}
    deleg = engine.flush_delegations
    assert_not_nil deleg
    assert_equal({:p0=>
          {0=>
            [["rule local2@test_pending_delegation_content('14') :- local@test_pending_delegation_content('4');"]]}},
      deleg)
    assert_equal({}, engine.pending_delegations)

    # test delegation model method
    assert_equal({}, engine.flush_delegations)
    # simulate reception of delgation by sending via the own channel of the peer
    # to itself HACKY only for the tests
    engine.sync_do {
      engine.chan <~ [["localhost:#{helper.port}",
          ["p0", "0",
            {"rules"=>["rule local2@test_pending_delegation_content('14') :- local@test_pending_delegation_content('4');"],
              "facts"=>{},
              "declarations"=>[]
            }]]]}
    Delegation.refresh_delegations
    p Delegation.all
    assert_equal [], Delegation.all
  end # def test_delegation
end # class
