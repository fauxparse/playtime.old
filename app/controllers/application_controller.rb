class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization

  before_filter :require_login

  rescue_from CanCan::AccessDenied do |exception|
    # TODO: show flash messages
    flash[:alert] = exception.message
    redirect_to root_url
  end

protected
  def current_session
    return @current_session if defined?(@current_session)
    @current_session = JesterSession.find
  end
  helper_method :current_session

  def current_jester
    return @current_jester if defined?(@current_jester)
    @current_jester = current_session.try :jester
  end
  helper_method :current_jester
  
  def logged_in?
    current_jester.present?
  end
  helper_method :logged_in?

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
  
  def current_ability
    @current_ability ||= Ability.new(current_jester)
  end
  
end
