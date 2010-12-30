class ShowsController < ApplicationController
  def index
    @month = date - date.day + 1
    @last_month = @month - 1.month
    @next_month = @month + 1.month
    @shows = Show.where("date >= ? AND date < ?", @month, @month + 1.month).includes(:players => :jester).index_by(&:date)
  end

  def show
    @show = Show.find_by_date(date, :include => { :players => :jester }) ||
            Show.new(:date => date)
  end
  
  def edit
    unless @show = Show.find_by_date(date, :include => { :players => :jester })
      redirect_to availability_path(*@show.params)
    end
  end
  
  def update
    @show = Show.find_by_date(date, :include => { :players => :jester })
    @show.update_attributes params[:show]
    redirect_to show_path(*@show.params)
  end

protected
  def date
    @date ||= Date.civil(
      (params[:year] || Date.today.year).to_i,
      (params[:month] || Date.today.month).to_i,
      (params[:day] || Date.today.day).to_i
    )
  end

end
