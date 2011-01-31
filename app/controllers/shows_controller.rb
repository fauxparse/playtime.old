class ShowsController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        @month = date - date.day + 1
        @last_month = @month - 1.month
        @next_month = @month + 1.month
        @shows = Show.where("date >= ? AND date < ?", @month, @month + 1.month).includes(:players => :jester).index_by(&:date)
      end
      
      format.ics do
        render :text => Show.calendar
      end
    end
  end
  skip_authorization_check :only => :index
  skip_before_filter :require_login, :only => :index

  def show
    @show = Show.find_by_date(date, :include => { :players => :jester }) ||
            Show.new(:date => date)
    authorize! :read, @show
  end
  
  def edit
    @show = Show.find_by_date(date, :include => { :players => :jester })
    unless @show
      redirect_to availability_path(*@show.params)
    end
    redirect_to show_path(*@show.params) unless can? :edit, @show
  end
  skip_authorization_check :only => :edit
  
  def update
    @show = Show.find_by_date(date, :include => { :players => :jester })
    authorize! :update, @show
    @show.update_attributes params[:show]
    redirect_to show_path(*@show.params)
  end

protected
  def date
    @date ||= if params[:year]
      if params[:month]
        if params[:day]
          Date.civil params[:year].to_i, params[:month].to_i, params[:day.to_i]
        else
          Date.civil params[:year].to_i, params[:month.to_i], 1]
        end
      else
        Date.civil params[:year].to_i, 1, 1
      end
    else
      Date.today
    end
  end

end
