class Github::TeamMember::Destroy
  include Mandate

  initialize_with :github_uid, :team_name

  def call
    return unless user
    return unless team_member

    team_member.delete
    User::UpdateMaintainer.(user)
  end

  memoize
  def user = User.find_by(uid: github_uid)

  memoize
  def team_member = Github::TeamMember.find_by(user:, team_name:)
end
