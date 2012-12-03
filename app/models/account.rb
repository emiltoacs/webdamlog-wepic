class Account < ActiveRecord::Base
  attr_accessible :ip, :port, :username
end
