class JesterSessionsController < ApplicationController
  skip_before_filter :require_login
  
  def new
    @jester_session = JesterSession.new
  end
  
  def create
    @jester_session = JesterSession.new(params[:jester_session])
    if @jester_session.save
      flash[:notice] = "You have logged in"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def destroy
    current_session.destroy
    flash[:notice] = "You have logged out"
    redirect_back_or_default login_path
  end
end