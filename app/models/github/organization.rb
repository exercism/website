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

  def remove_membership(_github_username)
    Exercism.octokit_client.remove_organization_membership(name, username)
  end

  def team_membership_count_for_user(github_username)
    query = <<~QUERY.strip
      {
        organization(login: "#{name}") {
          teams(userLogins: ["#{github_username}"]) {
            totalCount
          }
        }
      }
    QUERY

    response = Exercism.octokit_client.post("https://api.github.com/graphql", { query: query }.to_json).to_h
    response.dig(:data, :organization, :teams, :totalCount)
  end

  def member_usernames
    cursor = nil
    results = []

    loop do
      response = fetch_member_usernames(cursor)

      results += response[:data][:organization][:membersWithRole][:nodes].map { |member| member[:login] }
      break results unless response.dig(:data, :organization, :membersWithRole, :pageInfo, :hasNextPage)

      cursor = response.dig(:data, :organization, :membersWithRole, :pageInfo, :endCursor)
      handle_rate_limit(response.dig(:data, :rateLimit))
    end
  end

  def fetch_member_usernames(cursor)
    query = <<~QUERY.strip
      {
        organization(login: "#{name}") {
          membersWithRole(first: 100
                          #{%(, after: "#{cursor}") if cursor}) {
            nodes {
              login
            }
            pageInfo {
              hasNextPage
              endCursor
            }
          }
        }
        rateLimit {
          remaining
          resetAt
        }
      }
    QUERY

    Exercism.octokit_client.post("https://api.github.com/graphql", { query: query }.to_json).to_h
  end

  def team_member_usernames
    cursor = nil
    users = [].to_set

    loop do
      response = fetch_team_member_usernames(cursor)

      response.dig(:data, :organization, :teams, :nodes).each do |team|
        users |= team.dig(:members, :nodes).pluck(:login)
      end

      break users unless response.dig(:data, :organization, :teams, :pageInfo, :hasNextPage)

      cursor = response.dig(:data, :organization, :teams, :pageInfo, :endCursor)
      handle_rate_limit(response.dig(:data, :rateLimit))
    end
  end

  def fetch_team_member_usernames(cursor)
    query = <<~QUERY.strip
      {
        organization(login: "#{name}") {
          teams(first: 100 #{%(, after: "#{cursor}") if cursor}) {
            nodes {
              members {
                nodes {
                  login
                }
              }
            }
            pageInfo {
              hasNextPage
              endCursor
            }
          }
        }
        rateLimit {
          remaining
          resetAt
        }
      }
    QUERY

    Exercism.octokit_client.post("https://api.github.com/graphql", { query: query }.to_json).to_h
  end

  def handle_rate_limit(rate_limit_data)
    # If the rate limit was exceeded, sleep until it resets
    return if rate_limit_data[:remaining].positive?

    reset_at = Time.parse(rate_limit_data[:resetAt]).utc
    seconds_until_reset = reset_at - Time.now.utc
    sleep(seconds_until_reset.ceil)
  end
end
