class Player < ActiveRecord::Base
  belongs_to :show, :inverse_of => :players
  belongs_to :jester, :inverse_of => :availability
  
  scope :playing, where(:role => :player)
  scope :mcing, where(:role => :mc)
  scope :playing_or_mcing, where(:role => [ :player, :mc ])
  
  delegate :to_s, :image, :name, :to => :jester

  def role
    super.try :to_sym
  end

  def playing?
    role == :player
  end
  
  def mcing?
    role == :mc
  end
  
  def playing_or_mcing?
    role.present?
  end
  
  def date
    show.try :date
  end
  
end
