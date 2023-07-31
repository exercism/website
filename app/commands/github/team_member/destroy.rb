class Github::TeamMember::Destroy
  include Mandate

  initialize_with :user_id, :team_name

  def call = ::Github::TeamMember.where(user_id:, team_name:).destroy_all
end
