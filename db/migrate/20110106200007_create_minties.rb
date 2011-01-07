class CreateMinties < ActiveRecord::Migration
  def self.up
    create_table :minties_categories do |t|
      t.string :name
      t.string :cached_slug
      t.integer :minties_count, :null => false, :default => 0
    end
    
    create_table :minties do |t|
      t.belongs_to :category
      t.belongs_to :jester
      t.string :custom_category_name
      t.string :nominees
      t.text :nomination
      t.date :date
    end
    
    add_index :minties, [ :date, :category_id ]
    
    execute <<-SQL
      ALTER TABLE minties ADD CONSTRAINT fk_minties_category_id
        FOREIGN KEY (category_id) REFERENCES minties_categories (id)
        ON DELETE RESTRICT;
        
      ALTER TABLE minties ADD CONSTRAINT fk_minties_jester_id
        FOREIGN KEY (jester_id) REFERENCES jesters (id)
        ON DELETE CASCADE;
    SQL
  end

  def self.down
    drop_table :minties
    drop_table :minties_categories
  end
end
