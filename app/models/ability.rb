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
    end
  end
end