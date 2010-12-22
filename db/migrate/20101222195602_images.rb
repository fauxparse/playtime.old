class Images < ActiveRecord::Migration
  def self.up
    change_table :jesters do |t|
      t.string :image
    end
  end

  def self.down
    change_table :jesters do |t|
      t.remove :image
    end
  end
end
