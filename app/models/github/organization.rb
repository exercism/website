class Github::Organization
  include Mandate

  memoize
  def name
    ENV["GITHUB_ORGANIZATION"] || Exercism.config.github_organization
  end

  memoize
  def active?
    name.present?
  end

  def team_memberships_count(github_username)
    query = <<~QUERY.strip
      {
        organization(login: "exercism") {
          teams(userLogins: ["#{github_username}"]) {
            totalCount
          }
        }
      }
    QUERY

    response = Exercism.octokit_client.post("https://api.github.com/graphql", { query: query }.to_json).to_h
    response.dig(:data, :organization, :teams, :totalCount)
  end
end
