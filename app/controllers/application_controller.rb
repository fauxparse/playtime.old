class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_session, :current_jester
  before_filter :require_login

protected
  def current_session
    return @current_session if defined?(@current_session)
    @current_session = JesterSession.find
  end

  def current_jester
    return @current_jester if defined?(@current_jester)
    @current_jester = current_session.try :jester
  end

  def require_login
    unless current_jester
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_path
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
end
