class MintiesCategory < ActiveRecord::Base
  has_many :minties, :inverse_of => :minties
  
  has_friendly_id :name, :use_slug => true
  validates :name, :presence => true, :uniqueness => true
  
  alias_attribute :to_s, :name
end
