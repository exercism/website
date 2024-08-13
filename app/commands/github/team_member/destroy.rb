class Github::TeamMember::Destroy
  include Mandate

  initialize_with :github_uid, :team_name

  def call
    return unless user

    user.github_team_memberships.where(team_name:).delete_all.tap do
      User::UpdateMaintainer.(user)
    end
  end

  memoize
  def user = User.find_by(uid: github_uid)
end
