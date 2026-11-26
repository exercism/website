module User::Roles
  # Access comes in three levels. Each level can do everything the levels below it can.
  # - admin: anything with personal data, or that acts on users.
  # - maintainer_admin: running the site and the org.
  # - maintainer: maintaining tracks.
  def admin? = roles.include?(:admin)
  def maintainer_admin? = roles.include?(:maintainer_admin) || admin?
  def maintainer? = roles.include?(:maintainer) || maintainer_admin?

  # Labels. These change how someone is shown, but give no access.
  def founder? = roles.include?(:founder)
  def staff? = roles.include?(:staff) || admin?
  def supermentor? = roles.include?(:supermentor)

  # Moderation acts on users, so admins can always moderate.
  def moderator? = roles.include?(:moderator) || admin?
  def mentor? = became_mentor_at.present? || maintainer_admin?

  def roles = super.to_a.map(&:to_sym).to_set
end
