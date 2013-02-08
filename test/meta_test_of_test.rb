require 'test_helper'
require 'test/unit'

class MetaTestOfTest < Test::Unit::TestCase
  
  # The working directory is two directory above at the rails.root. It means
  # that have been launched from two directory above.
  def test_1_path
    # See . is set to working directory
    assert_equal(File.expand_path("."), File.expand_path('../..',__FILE__))
    # See default directory is the working directory
    assert_equal(Dir.pwd, File.expand_path('../..',__FILE__))
    # This file has been added to the list of path to look for files
    assert($:.include?(File.dirname(__FILE__)))
    # see the current working directory
    assert_equal(
      File.expand_path("~/research/webdam/webdamSystem/12Wepic/webdamsystem"),
      Dir.getwd)
    # see the current working file and line
    assert_equal(
      File.expand_path("~/research/webdam/webdamSystem/12Wepic/webdamsystem/test/meta_test_of_test.rb"),
      "#{__FILE__}")
  end  
end

