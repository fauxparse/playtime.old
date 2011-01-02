class NotesController < ApplicationController
  def create
    authorize! :create, Note
    @note = notable.notes.build((params[:note] || {}).merge(:author => current_jester))
    if @note.save
      redirect_to notable_path
    else
      # TODO: error out
    end
  end
  
  def destroy
    authorize! :destroy, note
    note.destroy
    redirect_to notable_path
  end
  
  def edit
    authorize! :edit, note
  end
  
  def update
    authorize! :edit, note
    note.update_attributes params[:note]
    redirect_to notable_path
  end

protected
  def note
    @note ||= notable.notes.find params[:id]
  end
  helper_method :note

  def notable
    @notable ||= if params[:year]
      Show.find_by_date Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    end
  end
  helper_method :notable
  
  def notable_path
    case notable
    when Show then show_path(*notable.params)
    end
  end

end
