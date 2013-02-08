require 'properties'
require 'wl_logger'
require 'wl_database'
require 'wl_launcher'

class ApplicationController < ActionController::Base
  include Properties
  include WLLogger
  
  protect_from_forgery
  
  helper_method :current_user
  helper_method :is_admin
  helper_method :port
  
  private
  #TODO : need to find a clean way to define our admin list.
  #@@adminlist = Array[3,4,5]
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
    @current_user_session
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def is_admin(user_id)
    return current_user.nil?#@@adminlist.include?(user_id)
  end
  
  
  #FIXME move to some utility module
  def exists(a,b)
    if a then a else b end
  end
end
