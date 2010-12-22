class Jester < ActiveRecord::Base
  acts_as_authentic do |config|
    
  end
  
  def name
    super || [ first_name, last_initial ].join(" ").strip
  end
  
  def last_initial
    last_name.try(:first).try :<<, '.'
  end
  
  alias_attribute :to_s, :name
  
end
