class Github::TeamMember::Create
  include Mandate

  initialize_with :github_uid, :team_name

  def call
    return unless user

    user.github_team_memberships.find_or_create_by!(team_name:).tap do
      User::UpdateMaintainer.(user)
    end
  end

  memoize
  def user = User.find_by(uid: github_uid)
end
