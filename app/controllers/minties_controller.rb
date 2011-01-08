class MintiesController < ApplicationController
  load_and_authorize_resource

  def index
    @minties = current_jester.minties.all
    categorised, custom = @minties.partition(&:category_id?)
    @grouped = categorised.group_by(&:category).to_a.sort_by { |a| a.first.to_s }
    @grouped.push [ nil, custom ] unless custom.empty?
  end
  
  def create
    @mintie = Mintie.new params[:mintie]
    @mintie.jester = current_jester
    @mintie.date ||= Date.today
    if @mintie.save
      flash[:info] = "Thanks for your nomination!"
      redirect_to minties_path
    else
      render :action => :new
    end
  end
  
  def destroy
    @mintie.destroy
    redirect_to minties_path
  end
  
  def edit
    
  end
  
  def update
    if @mintie.update_attributes params[:mintie]
      redirect_to minties_path
    else
      render :action => :edit
    end
  end

end
