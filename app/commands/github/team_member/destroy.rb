class Github::TeamMember::Destroy
  include Mandate

  initialize_with :user_id, :team_name

  def call
    return unless team_member

    team_member.delete
    User::UpdateMaintainer.(user) if user
  end

  private
  memoize
  def team_member = ::Github::TeamMember.find_by(user_id:, team_name:)

  memoize
  def user = User.find_by(uid: user_id)
end
