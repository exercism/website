class Github::TeamMember::Destroy
  include Mandate

  initialize_with :user_id, :team_name

  def call
    ::Github::TeamMember.where(user_id:, team_name:).destroy_all.tap do
      User::UpdateMaintainer.(user) if user
    end
  end

  memoize
  def user = User.find_by(uid: user_id)
end
