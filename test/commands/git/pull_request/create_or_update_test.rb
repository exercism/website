require "test_helper"

class Git::PullRequest::CreateOrUpdateTest < ActiveSupport::TestCase
  test "create pull request" do
    data =
      {
        url: "https://api.github.com/repos/exercism/ruby/pulls/2",
        repo: "exercism/ruby",
        pr_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
        pr_number: 2,
        state: "closed",
        action: "closed",
        author: "iHiD",
        labels: [],
        merged: true,
        reviews: [{ user: { login: "ErikSchierboom" } }],
        html_url: "https://github.com/exercism/ruby/pull/2"
      }

    pr = Git::PullRequest::CreateOrUpdate(data)

    assert_equal "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz", pr.node_id
    assert_equal 2, pr.number
    assert_equal "exercism/ruby", pr.repo
    assert_equal "iHiD", pr.author_github_username
    assert_equal data, pr.data
  end

  test "update pull request if data has changed" do
    pr = create :pull_request
    changed_data = pr.data
    changed_data.labels = ["new-label"]

    pr = Git::PullRequest::CreateOrUpdate(data)

    assert_equal changed_data, pr.data
  end

  test "does not update pull request if data has not changed" do
    pr = create :pull_request
    updated_at_before_call = pr.updated_at

    pr = Git::PullRequest::CreateOrUpdate(data)

    assert_equal updated_at_before_call, pr.reload.updated_at_before_call
  end
end
