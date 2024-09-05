class Webhooks::ProcessMembershipUpdate
  include Mandate

  initialize_with :action, :github_uid, :team_name, :organization_name

  def call
    return unless %(added removed).include?(action)
    return unless organization_name == organization.name

    case action
    when 'added'
      Github::TeamMember::Create.(user, team_name) if user
    when 'removed'
      Github::TeamMember::Destroy.(team_member) if team_member
    end
  end

  private
  memoize
  def organization = Github::Organization.instance

  memoize
  def user = User.find_by(uid: github_uid)

  memoize
  def team_member = Github::TeamMember.find_by(user:, team_name:)
end
