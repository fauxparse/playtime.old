class Note < ActiveRecord::Base
  belongs_to :notable, :polymorphic => true, :counter_cache => true
  belongs_to :author, :class_name => "Jester"
  
  include ActsAsSanitiled
  acts_as_textiled :content
  
end
