# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'active_record'
require 'test/unit'
require 'lib/database'
require 'lib/kernel'

#This class is meant to test and explain the database API to be used 
#by the rails controllers and WebdamLog.
#The suppress warning messages are used to avoid constant reassignment warnings.
#Constant reassignment should not be used in practice but is useful for purposes
#of testing.
#TODO : Avoid duplication of information in the Database module by reducing the 
#number of variables.
class DatabaseTest < Test::Unit::TestCase
  include Database
  include Kernel
  
  def setup
    @dbid = (0...8).map{('a'..'z').to_a[rand(26)]}.join
    @database = create_or_connect_db(@dbid)
  end
  
  def teardown
    @database.destroy
  end
  
  test "setup_and_teardown" do
    assert(true)
  end
  
  test "access schema from class" do
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    assert_equal(relation_schema,@database.relation_classes[relation_name].schema)
  end
  
  test "connect to db" do
    #Check if database was created during the setup
    assert_equal(WLInstanceDatabase,@database.class)
    #Check if database contains the WLSchema relation
    assert_equal({"name"=>"string","schema"=>"string"},@database.relation_classes["WLSchema"].schema)
    assert_equal("WLSchema",@database.relation_classes["WLSchema"].table_name)
  end
  
  #TODO enhance test by adding several relations to the testing.
  test "create relation" do
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    #Assert relations has been added to database schemas and relation class attributes.
    assert_equal("Dog",@database.relation_classes["Dog"].table_name)
  end
  
  test "deconnect" do
    close_connection(@dbid)
    assert_equal(nil,database(@dbid))
  end
  
  test "reconnection" do
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    close_connection(@dbid)    
    @database = create_or_connect_db(@dbid)
    #Schema should contain the Dog table information
    assert_equal(false,@database.relation_classes["WLSchema"].all.empty?)
    assert_equal("Dog",@database.relation_classes["WLSchema"].find(1).name)
  end
  
  #You can check that the dog was added to the database with the following commands:
  #sqlite3 db/database_2.db
  #SELECT * FROM DOG;
  test "insert and retrieve" do
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    dog_table = @database.relation_classes["Dog"]
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    dog_table.open_connection
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    bobby = dog_table.find(1)
    assert_equal("Bobby",bobby.name)
    assert_equal(2,bobby.age)
    assert_equal("labrador",bobby.race)
    dog_table.remove_connection
  end
  
  test "delete" do
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    dog_table = @database.relation_classes["Dog"]
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    dog_table.open_connection
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    dog_table.delete(1)
    assert_equal(true,dog_table.all.empty?)
    dog_table.remove_connection
  end
end
