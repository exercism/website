class Github::TeamMember::Create
  include Mandate

  initialize_with :username, :team

  def call = ::Github::TeamMember.find_create_or_find_by!(username:, team:)
end
