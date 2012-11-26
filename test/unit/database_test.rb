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
#TODO !!! Currently, support for several peers connecting simulatenously with
#identical table names is not supported!
#TODO : Avoid duplication of information in the Database module by reducing the 
#number of variables.
class DatabaseTest < Test::Unit::TestCase
  include Database
  include Kernel
  #TODO Remove user id. Need unit tests.
  @@database_id = 2
  
  test "connect to db" do
    database = suppress_warnings {create_or_connect_db(@@database_id)}
    #Check if database created is of the right class
    assert_equal(WLInstanceDatabase,database.class)
    #Check if database contains the WLSchema relation
    @wlschema_table_present=false
    database.schemas.each_pair do |table,table_schema|
      if "WLSCHEMA"==table.upcase
        assert_equal({"name"=>"string","schema"=>"string"},table_schema)
        @wlschema_table_present=true
      end
    end
    assert_equal(true,@wlschema_table_present)
    assert_equal("WLSchema",database.relations["WLSchema"].table_name)
  end
  
  #TODO enhance test by adding several relations to the testing.
  test "create relation" do
    database = suppress_warnings {database(@@database_id)}
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    suppress_warnings {database.create_relation(relation_name,relation_schema)}
    #Assert relations has been added to database schemas and relationclass attributes.
    assert_equal(true,database.schemas.keys.include?("Dog"))
    assert_equal("Dog",database.relations["Dog"].table_name)
  end
  
  test "deconnect" do
    suppress_warnings do
      create_or_connect_db(@@database_id)
    end
    close_connection(@@database_id)
    assert_equal(nil,database(@@database_id))

  end
  
  test "reconnection" do
    suppress_warnings {create_or_connect_db(@@database_id)}
    close_connection(@@database_id)    
    database = suppress_warnings {create_or_connect_db(@@database_id)}
    assert_equal(true,database.schemas.keys.include?("Dog"))
    #Schema should contain the Dog table information
    assert_equal(false,WLSchema.all.empty?)
    assert_equal("Dog",WLSchema.find(1).name)
  end
  
  #You can check that the dog was added to the database with the following commands:
  #sqlite3 db/database_2.db
  #SELECT * FROM DOG;
  test "insert and retrieve" do
    suppress_warnings {create_or_connect_db(@@database_id)}
    database = database(@@database_id)
    puts "error" if database.nil?
    dog_table = database.relations["Dog"]
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    bobby = dog_table.find(1)
    assert_equal("Bobby",bobby.name)
    assert_equal(2,bobby.age)
    assert_equal("labrador",bobby.race)
  end  
end
