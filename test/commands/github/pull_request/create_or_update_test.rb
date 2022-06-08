require "test_helper"

class Github::PullRequest::CreateOrUpdateTest < ActiveSupport::TestCase
  test "create pull request with reviewers" do
    node_id = "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz"
    number = 2
    repo = "exercism/ruby"
    author = "iHiD"
    merged_by = "ErikSchierboom"
    reviews = [{ node_id: "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4", reviewer_username: "ErikSchierboom" }]
    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo:,
      node_id:,
      number:,
      state: "closed",
      action: "closed",
      author_username: author,
      labels: [],
      merged: true,
      merged_by_username: merged_by,
      reviews:,
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      node_id,
      number:,
      author_username: author,
      merged_by_username: merged_by,
      repo:,
      reviews:,
      data:
    )

    assert_equal "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz", pr.node_id
    assert_equal 2, pr.number
    assert_equal "exercism/ruby", pr.repo
    assert_equal "iHiD", pr.author_username
    assert_equal "ErikSchierboom", pr.merged_by_username
    assert_equal data, pr.data
    assert_equal 1, pr.reviews.size
    assert_equal "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4", pr.reviews.first.node_id
    assert_equal "ErikSchierboom", pr.reviews.first.reviewer_username
  end

  test "create pull request without reviewers" do
    node_id = "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz"
    number = 2
    repo = "exercism/ruby"
    author = "iHiD"
    merged_by = "ErikSchierboom"
    reviews = []
    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo:,
      node_id:,
      number:,
      state: "closed",
      action: "closed",
      author_username: author,
      labels: [],
      merged: true,
      merged_by_username: merged_by,
      reviews:,
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      node_id,
      number:,
      author_username: author,
      merged_by_username: merged_by,
      repo:,
      reviews:,
      data:
    )

    assert_equal "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz", pr.node_id
    assert_equal 2, pr.number
    assert_equal "exercism/ruby", pr.repo
    assert_equal "iHiD", pr.author_username
    assert_equal "ErikSchierboom", pr.merged_by_username
    assert_equal data, pr.data
    assert_empty pr.reviews
  end

  test "update pull request if data has changed" do
    pr = create :github_pull_request
    changed_data = pr.data
    changed_data[:labels] = ["new-label"]

    Github::PullRequest::CreateOrUpdate.(
      pr.node_id,
      number: pr.number,
      author_username: pr.author_username,
      merged_by_username: pr.merged_by_username,
      repo: pr.repo,
      reviews: pr.reviews,
      data: changed_data
    )

    assert_equal changed_data, pr.reload.data
  end

  test "does not update pull request if data has not changed" do
    freeze_time do
      pr = create :github_pull_request
      updated_at_before_call = pr.updated_at

      Github::PullRequest::CreateOrUpdate.(
        pr.node_id,
        number: pr.number,
        author_username: pr.author_username,
        merged_by_username: pr.merged_by_username,
        repo: pr.repo,
        reviews: pr.reviews,
        data: pr.data
      )

      assert_equal updated_at_before_call, pr.reload.updated_at
    end
  end

  test "removes reviewers if no longer present" do
    pr = create :github_pull_request
    create :github_pull_request_review, pull_request: pr

    Github::PullRequest::CreateOrUpdate.(
      pr.node_id,
      number: pr.number,
      author_username: pr.author_username,
      merged_by_username: pr.merged_by_username,
      repo: pr.repo,
      reviews: [],
      data: pr.data
    )

    assert_empty pr.reload.reviews
  end
end
