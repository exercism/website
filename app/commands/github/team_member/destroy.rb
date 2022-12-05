class Github::TeamMember::Destroy
  include Mandate

  initialize_with :username, :team

  def call = ::Github::TeamMember.where(username:, team:).destroy_all
end
