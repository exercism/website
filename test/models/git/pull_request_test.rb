require "test_helper"

class Git::PullRequestTest < ActiveSupport::TestCase
  test "data" do
    pr = create :git_pull_request

    assert_equal 2, pr.data[:pr_number]
    assert_equal 'ErikSchierboom', pr.data[:reviews][0][:user][:login]
  end
end
