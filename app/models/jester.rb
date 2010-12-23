class Jester < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  acts_as_authentic do |config|
    
  end
  
  has_many :availability, :class_name => "Player", :inverse_of => :jester
  has_many :shows, :through => :availability
  
  has_friendly_id :name, :use_slug => true
  
  scope :active, where(:active => true)

  def name
    super || [ first_name, last_initial ].join(" ").strip
  end
  
  def last_initial
    last_name.try(:first).try :<<, '.'
  end
  
  alias_attribute :to_s, :name
  
  def role
    super.try :to_sym
  end
  
  def ratio(playing = nil)
    playing ||= availability.all
  end
  
  def last_played
    shows.as_player.where("date < ?", Date.today).includes(:players => :jester).last
  end
  memoize :last_played
  
  def last_played_on
    last_played.try :date
  end
  
  def last_mced
    shows.as_mc.where("date < ?", Date.today).includes(:players => :jester).last
  end
  memoize :last_mced
  
  def last_mced_on
    last_mced.try :date
  end
  
  def percentage(window = 90.days)
    100.0 * shows.as_player.after(window.ago).count /
    shows.after(window.ago).count
  end
  memoize :percentage
  
end
