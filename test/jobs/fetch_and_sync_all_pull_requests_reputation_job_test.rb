require "test_helper"

class FetchAndSyncAllPullRequestsReputationJobTest < ActiveJob::TestCase
  test "github pull requests are synced" do
    stub_requests

    Github::OrganizationMember::SyncMembers.expects(:call)

    Github::PullRequest::SyncRepos.expects(:call)

    FetchAndSyncAllPullRequestsReputationJob.perform_now
  end

  test "github organization members are synced" do
    stub_requests

    Github::OrganizationMember::SyncMembers.expects(:call)

    FetchAndSyncAllPullRequestsReputationJob.perform_now
  end

  test "reputation is awarded for pull requests" do
    stub_requests

    Github::OrganizationMember::SyncMembers.stubs(:call)

    User::ReputationToken::AwardForPullRequests.expects(:call)

    FetchAndSyncAllPullRequestsReputationJob.perform_now
  end

  private
  def stub_requests
    RestClient.unstub(:get)
    RestClient.unstub(:post)

    stub_request(:get, "https://api.github.com/search/repositories?per_page=100&q=org:exercism%20is:public").
      to_return(
        status: 200,
        body: { items: [{ full_name: 'exercism/csharp' }] }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://api.github.com/graphql").
      to_return(status: 200, body:
        {
          data: {
            organization: {
              membersWithRole: {
                nodes: [
                  { login: 'ErikSchierboom' }
                ],
                pageInfo: {
                  hasNextPage: false,
                  endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
                }
              }
            },
            rateLimit: {
              remaining: 4991,
              resetAt: '2021-03-10T15:32:50Z'
            }
          }
        }.to_json, headers: { 'Content-Type': 'application/json' })
  end
end
