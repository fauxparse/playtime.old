class Player < ActiveRecord::Base
  belongs_to :show, :inverse_of => :players
  belongs_to :jester, :inverse_of => :availability
  
  scope :playing, where(:role => :player)
  scope :mcing, where(:role => :mc)
  scope :playing_or_mcing, where(:role => [ :player, :mc ])
end
