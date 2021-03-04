require "test_helper"

class Github::ImportPullRequestsTest < ActiveSupport::TestCase
  test "imports all pull requests" do
    track = create :track, slug: 'babashka'

    # TODO: add test
    Github::ImportPullRequests.(track)
  end
end
