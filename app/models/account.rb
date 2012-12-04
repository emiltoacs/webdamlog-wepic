class Account < ActiveRecord::Base
  attr_accessible :ip, :port, :username
  attr_accessible :active
end
