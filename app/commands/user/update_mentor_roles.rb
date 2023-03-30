class User::UpdateMentorRoles
  include Mandate

  initialize_with :user

  def call
    if Mentor::Supermentor.eligible?(user)
      User::AddRoles.(user, [Mentor::Supermentor::ROLE])
      AwardBadgeJob.perform_later(user, :supermentor)
    else
      User::RemoveRoles.(user, [Mentor::Supermentor::ROLE])
    end
  end
end
