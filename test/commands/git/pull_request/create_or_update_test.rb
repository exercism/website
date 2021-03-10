require "test_helper"

class Git::PullRequest::CreateOrUpdateTest < ActiveSupport::TestCase
  test "create pull request with reviewers" do
    pr_id = "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz"
    pr_number = 2
    repo = "exercism/ruby"
    author = "iHiD"
    reviews = [{ node_id: "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4", reviewer: "ErikSchierboom" }]
    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo: repo,
      pr_id: pr_id,
      pr_number: pr_number,
      state: "closed",
      action: "closed",
      author: author,
      labels: [],
      merged: true,
      reviews: reviews,
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    pr = Git::PullRequest::CreateOrUpdate.(pr_id,
      pr_number: pr_number,
      author: author,
      repo: repo,
      reviews: reviews,
      data: data)

    assert_equal "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz", pr.node_id
    assert_equal 2, pr.number
    assert_equal "exercism/ruby", pr.repo
    assert_equal "iHiD", pr.author_github_username
    assert_equal data, pr.data
    assert_equal 1, pr.reviews.size
    assert_equal "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4", pr.reviews.first.node_id
    assert_equal "ErikSchierboom", pr.reviews.first.reviewer_github_username
  end

  test "create pull request without reviewers" do
    pr_id = "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz"
    pr_number = 2
    repo = "exercism/ruby"
    author = "iHiD"
    reviews = []
    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo: repo,
      pr_id: pr_id,
      pr_number: pr_number,
      state: "closed",
      action: "closed",
      author: author,
      labels: [],
      merged: true,
      reviews: reviews,
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    pr = Git::PullRequest::CreateOrUpdate.(pr_id,
      pr_number: pr_number,
      author: author,
      repo: repo,
      reviews: reviews,
      data: data)

    assert_equal "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz", pr.node_id
    assert_equal 2, pr.number
    assert_equal "exercism/ruby", pr.repo
    assert_equal "iHiD", pr.author_github_username
    assert_equal data, pr.data
    assert_empty pr.reviews
  end

  test "update pull request if data has changed" do
    pr = create :git_pull_request
    changed_data = pr.data
    changed_data[:labels] = ["new-label"]

    pr = Git::PullRequest::CreateOrUpdate.(pr.node_id,
      pr_number: pr.number,
      author: pr.author_github_username,
      repo: pr.repo,
      reviews: pr.reviews,
      data: changed_data)

    assert_equal changed_data, pr.data
  end

  test "does not update pull request if data has not changed" do
    pr = create :git_pull_request
    updated_at_before_call = pr.updated_at

    pr = Git::PullRequest::CreateOrUpdate.(pr.node_id,
      pr_number: pr.number,
      author: pr.author_github_username,
      repo: pr.repo,
      reviews: pr.reviews,
      data: pr.data)

    assert_equal updated_at_before_call, pr.reload.updated_at
  end

  test "removes reviewers if no longer present" do
    pull_request = create :git_pull_request
    create :git_pull_request_review, pull_request: pull_request

    Git::PullRequest::CreateOrUpdate.(pull_request.node_id,
      pr_number: pull_request.number,
      author: pull_request.author_github_username,
      repo: pull_request.repo,
      reviews: [],
      data: pull_request.data)

    assert_empty pull_request.reload.reviews
  end
end
