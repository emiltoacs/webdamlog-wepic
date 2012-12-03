class Account < ActiveRecord::Base
  attr_accessible :active, :location, :username, :pid
end
