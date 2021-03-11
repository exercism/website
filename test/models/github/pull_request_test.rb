require "test_helper"

class Github::PullRequestTest < ActiveSupport::TestCase
  test "data can be accessed using symbols" do
    pr = create :github_pull_request

    assert_equal "exercism/ruby", pr.data[:repo]
    assert_equal 2, pr.data[:pr_number]
    assert_equal "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz", pr.data[:pr_id]
  end
end
