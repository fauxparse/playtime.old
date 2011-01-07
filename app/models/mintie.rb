class Mintie < ActiveRecord::Base
  belongs_to :jester
  belongs_to :category, :class_name => "MintiesCategory", :inverse_of => :minties, :counter_cache => true
  
  scope :this_year, lambda { y = Date.civil(Date.today.year, 1, 1); where("date >= ? AND date < ?", y, y + 1.year) }
  
  validates_presence_of :nominees
  validates_presence_of :custom_category_name, :unless => :category_id?
  
  include ActsAsSanitiled
  acts_as_textiled :content
  
end
