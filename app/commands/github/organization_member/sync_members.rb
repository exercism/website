module Github
  class OrganizationMember
    class SyncMembers
      include Mandate

      def call
        organization_member_usernames.each do |username|
          ::Github::OrganizationMember.create_or_find_by!(username: username)
        end

        ::Github::OrganizationMember.where.not(username: organization_member_usernames).destroy_all
      end

      private
      memoize
      def organization_member_usernames
        cursor = nil
        results = []

        loop do
          page_data = fetch_page(cursor)

          results += page_data[:data][:organization][:membersWithRole][:nodes].map { |member| member[:login] }
          break results unless page_data.dig(:data, :organization, :membersWithRole, :pageInfo, :hasNextPage)

          cursor = page_data.dig(:data, :organization, :membersWithRole, :pageInfo, :endCursor)
          handle_rate_limit(page_data.dig(:data, :rateLimit))
        end
      end

      def fetch_page(cursor)
        query = <<~QUERY.strip
          query {
            organization(login: "exercism") {#{'    '}
              membersWithRole(first: 100
                              #{%(, after: "#{cursor}") if cursor}) {
                nodes {
                  login
                }#{'      '}
                pageInfo {
                  hasNextPage
                  endCursor
                }#{' '}
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
  end
end
