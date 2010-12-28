class ShowSlugs < ActiveRecord::Migration
  def self.up
    change_table :shows do |t|
      t.string :cached_slug
    end
  end

  def self.down
    change_table :shows do |t|
      t.remove :cached_slug
    end
  end
end
