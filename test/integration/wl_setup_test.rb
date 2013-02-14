require 'test_helper'
require 'wl_setup'

class WLSetupTest < ActionController::IntegrationTest

  def test_clean_orphaned_peer
    assert File.exists?("db")
    assert_equal Rails.root, Pathname.getwd
    File.delete('db/database_MANAGER.db') if File.exists?('db/database_MANAGER.db')
    WLSetup.clean_orphaned_peer(DBConf.config[:adapter])
    assert Dir['your_directory/*'].empty?
    File.new('db/database_MANAGER.db', 'w')
    File.new('db/database_OTHERPEER.db', 'w')
    # See the two notation for glob Dir[] or Dir.glob()
    assert_equal 2, Dir['db/database_*.db'].length, "there should be two datases"
    WLSetup.clean_orphaned_peer(DBConf.config[:adapter])
    assert_equal 2, Dir.glob('db/database_*.db').length, "there should be one datases"
    system 'rm db/database_*.db'
    assert_equal 0, Dir.glob('db/database_*.db').length, "there should be zero datases"
  end

  

end
