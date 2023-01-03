# TODO: re-enable class once the organization functionality has been tested properly
# and this functionality is no longer user
class Github::Issue::OpenForOrganizationMemberRemove
  include Mandate

  initialize_with :organization, :github_username

  def call
    Github::Issue::Open.(repo, title, body)
  end

  private
  def repo
    "exercism/erikschierboom"
  end

  def title
    "🤖 Attempt to remove member `#{github_username}` from org `#{organization}`"
  end

  def body
    <<~BODY.strip
      The system tried to automatically remove the user `#{github_username}` from the `#{organization}` organization.

      CC @exercism/maintainers-admin
    BODY
  end
end
