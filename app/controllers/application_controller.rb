require 'wl_logger'
require 'wl_database'
require 'wl_launcher'

class ApplicationController < ActionController::Base
  include WLLogger
  
  protect_from_forgery
  
  helper_method :current_user
  helper_method :is_admin
  
  #filter_parameter_logging :password, :password_confirmation
  helper_method :current_admin_session, :current_admin
  
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
  
  def is_admin(user_id=nil)
    return !current_user.nil?#@@adminlist.include?(user_id)
  end

  def current_admin_session
    return @admin_user_session if defined?(@admin_user_session)
    @admin_user_session = AdminSession.find
  end

  def current_admin
    return @admin_user if defined?(@admin_user)
    @admin_user = current_admin_session && current_admin_session.admin
  end
  
end
