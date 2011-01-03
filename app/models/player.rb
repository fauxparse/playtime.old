class Player < ActiveRecord::Base
  belongs_to :show, :inverse_of => :players
  belongs_to :jester, :inverse_of => :availability
  
  scope :playing, where(:role => :player)
  scope :mcing, where(:role => :mc)
  scope :musoing, where(:role => :muso)
  scope :playing_or_mcing, where(:role => [ :player, :mc ])
  
  delegate :to_s, :image, :name, :to => :jester
  
  before_save :nil_not_blank!

  def role
    super.try :to_sym
  end

  def playing?
    role == :player
  end
  
  def mcing?
    role == :mc
  end
  
  def musoing?
    role == :muso
  end
  
  def playing_or_mcing?
    !role.blank?
  end
  
  def date
    show.try :date
  end

protected
  def nil_not_blank!
    self.role = nil if self.role.blank?
  end
    
end
