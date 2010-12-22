class CreateSlugs < ActiveRecord::Migration
  def self.up
    create_table :slugs do |t|
      t.string :name
      t.integer :sluggable_id
      t.integer :sequence, :null => false, :default => 1
      t.string :sluggable_type, :limit => 40
      t.string :scope
      t.datetime :created_at
    end
    add_index :slugs, :sluggable_id
    add_index :slugs, [:name, :sluggable_type, :sequence, :scope], :name => "index_slugs_on_n_s_s_and_s", :unique => true
    
    change_table :jesters do |t|
      t.string :cached_slug
    end
    add_index :jesters, :cached_slug, :unique => true
  end

  def self.down
    change_table :jesters do |t|
      t.remove :cached_slug
    end

    drop_table :slugs
  end
end
