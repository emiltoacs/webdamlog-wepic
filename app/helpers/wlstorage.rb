# To change this template, choose Tools | Templates
# and open the template in the editor.

module WLStorage
  #include ActiveRecord::Migration
		#XXX:if we use railsDB for WL storage
		#we would need functions here?
		#Maybe better to isolate functionality in a module.

		#Creates a new relation in the rails database
		#according to the schema for the relation.   
		def add_to_railsdb(schema,options={})			    
		end

		def store_data
      
    end    
end
