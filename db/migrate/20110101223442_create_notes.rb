class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.belongs_to :notable, :polymorphic => true
      t.belongs_to :author
      t.text :content
      t.timestamps
    end
    
    add_index :notes, [ :notable_type, :notable_id ]
    
    execute <<-SQL
      ALTER TABLE notes ADD CONSTRAINT fk_note_author
        FOREIGN KEY (author_id) REFERENCES jesters(id)
        ON DELETE CASCADE;
    SQL
    
    change_table :shows do |t|
      t.integer :notes_count, :null => false, :default => 0
    end
  end

  def self.down
    change_table :shows do |t|
      t.remove :notes_count
    end
    drop_table :notes
  end
end
