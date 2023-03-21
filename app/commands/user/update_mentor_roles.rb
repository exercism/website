class User::UpdateMentorRoles
  include Mandate

  initialize_with :user

  def call
    if Mentor::Supermentor.eligible?(user)
      User::UpdateRoles.(user, user.roles.add(Mentor::Supermentor::ROLE))
      AwardBadgeJob.perform_later(user, :supermentor)
    else
      User::UpdateRoles.(user, user.roles.delete(Mentor::Supermentor::ROLE))
    end
  end
end
