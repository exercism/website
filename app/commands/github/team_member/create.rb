class Github::TeamMember::Create
  include Mandate

  initialize_with :user_id, :team_name

  def call
    ::Github::TeamMember.find_create_or_find_by!(user_id:, team_name:).tap do
      User::UpdateMaintainer.(user) if user
    end
  end

  memoize
  def user = User.find_by(uid: user_id)
end
