class Account < ActiveRecord::Base
  attr_accessible :ip, :port, :username
  attr_accessible :active
  validates :username, :format => { :with => /\A[a-zA-Z]+\z/,
    :message => "Only letters allowed (between 5 and 20)", :length => {:minimum => 5, :maximum => 20} }
end
