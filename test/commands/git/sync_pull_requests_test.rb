require "test_helper"

class Git::SyncPullRequestsTest < ActiveSupport::TestCase
  test "syncs all repos" do
    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/search/repositories?per_page=100&q=org:exercism%20is:public").
      to_return(
        status: 200,
        body: { items: [{ full_name: 'exercism/csharp' }] }.to_json,
        headers: {
          'Link': "<https://api.github.com/search/repositories?per_page=100&q=org:exercism%20is:public&page=2>; rel=\"next\", <https://api.github.com/search/repositories?per_page=100&q=org:exercism%20is:public&page=2>; rel=\"last\"", # rubocop:disable Layout/LineLength
          'Content-Type': 'application/json'
        }
      )

    stub_request(:get, "https://api.github.com/search/repositories?page=2&per_page=100&q=org:exercism%20is:public").
      to_return(
        status: 200,
        body: { items: [{ full_name: 'exercism/ruby' }] }.to_json,
        headers: {
          'Link': "<https://api.github.com/search/repositories?per_page=100&q=org:exercism%20is:public&page=2>; rel=\"last\"", # rubocop:disable Layout/LineLength
          'Content-Type': 'application/json'
        }
      )

    Git::SyncPullRequestsForRepo.expects(:call).with('exercism/csharp')
    Git::SyncPullRequestsForRepo.expects(:call).with('exercism/ruby')

    Git::SyncPullRequests.()
  end
end
