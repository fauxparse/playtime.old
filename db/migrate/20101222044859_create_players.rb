class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.belongs_to :show, :null => false
      t.belongs_to :jester, :null => false
      t.string :role
    end
  end

  def self.down
    drop_table :players
  end
end
