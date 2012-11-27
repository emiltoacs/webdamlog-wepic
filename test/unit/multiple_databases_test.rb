# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'test/unit'
require 'active_record'
require 'lib/database'

class MultipleDatabasesTest < Test::Unit::TestCase
  include Database
  
  def setup
    @dbids = Array.new
    (0..7).each do |i|
      @dbids[i] =  (0...8).map{('a'..'z').to_a[rand(26)]}.join
      create_or_connect_db(@dbids[i])
    end
  end
  
  def teardown
    (0..7).each do |i|
      database(@dbids[i]).destroy
    end
  end
  
  test "manipulate several databases" do
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    @dbids.each do |id|
      database(id).create_relation(relation_name,relation_schema)
      assert_equal("Dog",database(id).relation_classes["Dog"].table_name)
    end
    @dbids.each do |id|
      database(id).relation_classes["Dog"].insert(values)
      bobby = database(id).relation_classes["Dog"].find(1)
      assert_equal("Bobby",bobby.name)
      assert_equal(2,bobby.age)
      assert_equal("labrador",bobby.race)      
    end
    @dbids.each do |id|
      database(id).relation_classes["Dog"].delete(1)
      assert_equal(true,database(id).relation_classes["Dog"].all.empty?)
    end
  end
end
