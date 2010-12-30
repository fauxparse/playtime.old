class DataController < ApplicationController
  def index
    authorize! :read, jester
    @data = jester.availability.includes(:show).order("shows.date").all
    respond_to do |format|
      format.json do
        render :json => {
          # :average => (@data.first.date..Date.today).map { |date|
          #   slice = @data.select { |d| (d.date >= date - 3.months) && (d.date <= date) }
          #   slice.any? ? (100.0 * slice.select { |d| d.role.present? }.count / slice.count) : 0.0
          # },
          :points => @data.map { |d| [ d.date, d.role || :available ] }
        }
      end
    end
  end

protected
  def jester
    @jester ||= Jester.find params[:jester_id]
  end

end
