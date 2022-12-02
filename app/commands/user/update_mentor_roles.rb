class User::UpdateMentorRoles
  include Mandate

  initialize_with :user

  def call
    if Mentor::Supermentor.eligible?(user)
      user.update(roles: user.roles.add(Mentor::Supermentor::ROLE))
      AwardBadgeJob.perform_later(user, :supermentor)
    else
      user.update(roles: user.roles.delete(Mentor::Supermentor::ROLE))
    end
  end
end
