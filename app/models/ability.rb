class Ability
  include CanCan::Ability

  def initialize(jester)
    if jester.admin?
      can :manage, :all
    else
      can :read, Jester
      can :update, Jester do |subject|
        jester == subject
      end
      
      can :read, Show
      can :update, Show do |show|
        show.mcs.include?(jester)
      end
      
      can :create, Note
      can [ :update, :destroy ], Note do |note|
        note.author_id == jester.id
      end
      
      can :create, Mintie
      can :read, Mintie do |mintie|
        mintie.jester_id == jester.id
      end
    end
  end
  
end