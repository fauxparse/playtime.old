class AvailabilityController < ApplicationController
  def show
    shows
  end
  
  def update
    params[:shows] ||= {}
    shows.each do |show|
      show.update_attributes(params[:shows][show.date.to_s(:db)] || { :availability => [] })
    end
    redirect_to availability_path(date.year, date.month, date.day)
  end

protected
  def shows
    @shows ||= dates.map { |d| Show.find_or_initialize_by_date(d) }
  end

  def date
    @date ||= if params[:year].present?
      Date.civil params[:year].to_i, (params[:month] || 1).to_i, (params[:day] || 1).to_i
    else
      Date.today + 7
    end
    @date - @date.wday
  end
  
  def dates
    @dates ||= [date + 5, date + 6]
  end

end
