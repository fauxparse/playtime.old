# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110106200007) do

  create_table "jesters", :force => true do |t|
    t.string   "first_name",                                :null => false
    t.string   "last_name"
    t.string   "name"
    t.boolean  "admin",               :default => false,    :null => false
    t.boolean  "active",              :default => true,     :null => false
    t.string   "email",                                     :null => false
    t.string   "crypted_password",                          :null => false
    t.string   "password_salt",                             :null => false
    t.string   "persistence_token",                         :null => false
    t.string   "single_access_token",                       :null => false
    t.string   "perishable_token",                          :null => false
    t.integer  "login_count",         :default => 0,        :null => false
    t.integer  "failed_login_count",  :default => 0,        :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
    t.string   "image"
    t.string   "type",                :default => "Jester", :null => false
  end

  add_index "jesters", ["cached_slug"], :name => "index_jesters_on_cached_slug", :unique => true
  add_index "jesters", ["type", "active"], :name => "index_jesters_on_type_and_active"

  create_table "minties", :force => true do |t|
    t.integer "category_id"
    t.integer "jester_id"
    t.string  "custom_category_name"
    t.string  "nominees"
    t.text    "nomination"
    t.date    "date"
  end

  add_index "minties", ["date", "category_id"], :name => "index_minties_on_date_and_category_id"

  create_table "minties_categories", :force => true do |t|
    t.string  "name"
    t.string  "cached_slug"
    t.integer "minties_count", :default => 0, :null => false
  end

  create_table "notes", :force => true do |t|
    t.integer  "notable_id"
    t.string   "notable_type"
    t.integer  "author_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["notable_type", "notable_id"], :name => "index_notes_on_notable_type_and_notable_id"

  create_table "players", :force => true do |t|
    t.integer "show_id",   :null => false
    t.integer "jester_id", :null => false
    t.string  "role"
  end

  create_table "shows", :force => true do |t|
    t.date     "date",                           :null => false
    t.boolean  "locked",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
    t.integer  "notes_count", :default => 0,     :null => false
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

end
