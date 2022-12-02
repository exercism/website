class User::UpdateMentorRoles
  include Mandate

  initialize_with :user

  def call
    if supermentor?
      user.update(roles: user.roles.add(Mentor::Supermentor::ROLE))
      AwardBadgeJob.perform_later(user, :supermentor)
    else
      user.update(roles: user.roles.delete(Mentor::Supermentor::ROLE))
    end
  end

  private
  def supermentor? = Mentor::Supermentor.eligible?(user)
end
