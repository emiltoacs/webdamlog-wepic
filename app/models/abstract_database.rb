# Super class of all my model used to specify generic properties
#
class AbstractDatabase < ActiveRecord::Base  
  self.abstract_class = true
  establish_connection ::Conf.db
end
