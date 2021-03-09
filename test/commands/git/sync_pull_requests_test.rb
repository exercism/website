require "test_helper"

class Git::SyncPullRequestsTest < ActiveSupport::TestCase
  test "syncs all repos without created_after" do
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

    Git::SyncPullRequestsForRepo.expects(:call).with('exercism/csharp', created_after: nil)
    Git::SyncPullRequestsForRepo.expects(:call).with('exercism/ruby', created_after: nil)

    Git::SyncPullRequests.()
  end

  test "syncs all repos with created_after" do
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

    created_after = 2.days.ago

    Git::SyncPullRequestsForRepo.expects(:call).with('exercism/csharp', created_after: created_after)
    Git::SyncPullRequestsForRepo.expects(:call).with('exercism/ruby', created_after: created_after)

    Git::SyncPullRequests.(created_after: created_after)
  end
end
