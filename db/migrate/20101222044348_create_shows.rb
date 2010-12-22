class CreateShows < ActiveRecord::Migration
  def self.up
    create_table :shows do |t|
      t.date :date, :null => false
      t.boolean :locked, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :shows
  end
end
