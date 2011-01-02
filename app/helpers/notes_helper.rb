module NotesHelper
  def edit_note_path(note, *args)
    case note.notable
    when Show then edit_show_note_path(*(note.notable.params + [ note.id ] + args))
    end
  end

  def note_path(note, *args)
    case note.notable
    when Show then show_note_path(*(note.notable.params + [ note.id ] + args))
    end
  end
  
end
