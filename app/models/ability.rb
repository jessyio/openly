# frozen_string_literal: true

# Define user permissions
class Ability
  include CanCan::Ability

  # rubocop:disable Metrics/MethodLength
  def initialize(user)
    return unless user

    # Users can manage their own profiles
    can :manage, User, id: user.id

    # Users can edit the projects of profiles that they can manage
    can %i[edit update destroy], Project do |project|
      can? :manage, project.owner
    end

    can %i[new create edit_content update_content],
        VersionControl::File do |_file, project|
      can? :edit, project
    end

    can %i[edit_name update_name delete delete destroy],
        VersionControl::File do |file, project|
      can?(:edit, project) && (file.name_was != 'Overview')
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
  # rubocop:enable Metrics/MethodLength
end