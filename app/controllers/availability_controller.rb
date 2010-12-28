class AvailabilityController < ApplicationController
  def show
    shows
  end
  
  def update
    params[:shows] ||= {}
    shows.each do |show|
      show.update_attributes(params[:shows][show.date.to_s(:db)] || { :availability => [] })
    end
    redirect_to availability_path(date)
  end

protected
  def shows
    @shows ||= dates.map { |d| Show.find_or_initialize_by_date(d) }
  end

  def date
    @date ||= if params[:date].present?
      Date.parse params[:date]
    else
      Date.today + 7
    end
    @date - @date.wday
  end
  
  def dates
    @dates ||= [date + 5, date + 6]
  end

end
