class CreateMusos < ActiveRecord::Migration
  def self.up
    change_table :jesters do |t|
      t.string :type, :null => false, :default => "Jester"
    end
    add_index :jesters, [ :type, :active ]
  end

  def self.down
    change_table :jesters do |t|
      t.remove :type
    end
  end
end
