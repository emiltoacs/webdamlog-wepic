class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user
  helper_method :is_admin
  
  private
  #TODO : need to find a clean way to define our admin list.
  #@@adminlist = Array[3,4,5]
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def is_admin(user_id)
    return current_user.nil?#@@adminlist.include?(user_id)
  end
end