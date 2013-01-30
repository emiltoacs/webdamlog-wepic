class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user
  helper_method :is_admin
  helper_method :port
  
  private
  #TODO : need to find a clean way to define our admin list.
  #@@adminlist = Array[3,4,5]
  
  def current_user_session
    return @current_user_session if @current_user_session
    @current_user_session = UserSession.find
    WLLogger.logger.info "Current session not already defined. Looking for session : #{exists(@current_user_session,"empty")}"
    @current_user_session
  end
  
  def current_user
    return @current_user if @current_user
    WLLogger.logger.info "Current User not already defined. Accessing session : #{exists(current_user_session,"no session")}"
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
