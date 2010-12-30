class JestersController < ApplicationController
  before_filter :load_jesters, :only => :index
  load_and_authorize_resource

  def index
  end
  
  def new
  end
  
  def create
    @jester = Jester.new(params[:jester])
    if @jester.save_without_session_maintenance
      flash[:notice] = "Account registered!"
      redirect_back_or_default jester_path(@jester)
    else
      render :action => :new
    end
  end
  
  def show
    @jester = params[:id] ? Jester.find(params[:id]) : current_jester
  end

  def edit
    @jester = params[:id] ? Jester.find(params[:id]) : current_jester
  end
  
  def update
    @jester = params[:id] ? Jester.find(params[:id]) : current_jester
    if @jester.update_attributes(params[:jester])
      flash[:notice] = "Account updated!"
      redirect_to jester_path(@jester)
    else
      render :action => :edit
    end
  end
  
protected
  def load_jesters
    @jesters = Jester.active.all(:include => { :availability => :show }).to_a
  end
  
end
