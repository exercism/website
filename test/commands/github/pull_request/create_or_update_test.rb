require "test_helper"

class Github::PullRequest::CreateOrUpdateTest < ActiveSupport::TestCase
  test "create pull request with reviewers" do
    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo: "exercism/ruby",
      title: "A fine PR",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: author,
      labels: [],
      merged: true,
      merged_by_username: "ErikSchierboom",
      reviews: [{ node_id: "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4", reviewer_username: "ErikSchierboom" }],
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      data[:node_id], **data.slice(:number, :title, :state, :author_username, :merged_by_username, :repo, :reviews).merge(data:)
    )

    assert_equal "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz", pr.node_id
    assert_equal 2, pr.number
    assert_equal "A fine PR", pr.title
    assert_equal "exercism/ruby", pr.repo
    assert_equal :closed, pr.state
    assert_equal "iHiD", pr.author_username
    assert_equal "ErikSchierboom", pr.merged_by_username
    assert_equal data, pr.data
    assert_equal 1, pr.reviews.size
    assert_equal "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTk5ODA2NTI4", pr.reviews.first.node_id
    assert_equal "ErikSchierboom", pr.reviews.first.reviewer_username
  end

  test "create pull request without reviewers" do
    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo: "exercism/ruby",
      title: "A fine PR",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: author,
      labels: [],
      merged: true,
      merged_by_username: "ErikSchierboom",
      reviews: [],
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      data[:node_id], **data.slice(:number, :title, :state, :author_username, :merged_by_username, :repo, :reviews).merge(data:)
    )

    assert_equal "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz", pr.node_id
    assert_equal 2, pr.number
    assert_equal "exercism/ruby", pr.repo
    assert_equal :closed, pr.state
    assert_equal "iHiD", pr.author_username
    assert_equal "ErikSchierboom", pr.merged_by_username
    assert_equal data, pr.data
    assert_empty pr.reviews
  end

  test "update pull request if data has changed" do
    pr = create :github_pull_request
    changed_data = pr.data.merge(labels: ["new-label"])

    Github::PullRequest::CreateOrUpdate.(
      pr.node_id,
      title: pr.title,
      number: pr.number,
      state: pr.state,
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
        title: pr.title,
        number: pr.number,
        state: pr.state,
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
      title: pr.title,
      number: pr.number,
      state: pr.state,
      author_username: pr.author_username,
      merged_by_username: pr.merged_by_username,
      repo: pr.repo,
      reviews: [],
      data: pr.data
    )

    assert_empty pr.reload.reviews
  end

  test "adds open metric for track pr" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'
    author = create :user, github_username: 'iHiD'

    data = {
      repo: "exercism/ruby",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: "iHiD",
      merged: true,
      merged_by_username: "ErikSchierboom",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      data[:node_id],
      **data.merge(data:)
    )

    perform_enqueued_jobs

    assert_equal 1, Metric.where(metric_action: :open_pull_request).count
    metric = Metric.where(metric_action: :open_pull_request).last
    assert_equal pr.data[:created_at].to_time, metric.created_at
    assert_equal :open_pull_request, metric.metric_action
    assert_equal track, metric.track
    assert_equal author, metric.user
  end

  test "adds open metric for non-track pr" do
    author = create :user, github_username: 'iHiD'

    data = {
      repo: "exercism/configlet",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: "iHiD",
      merged: true,
      merged_by_username: "ErikSchierboom",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      data[:node_id],
      **data.merge(data:)
    )

    perform_enqueued_jobs

    assert_equal 1, Metric.where(metric_action: :open_pull_request).count
    metric = Metric.where(metric_action: :open_pull_request).last
    assert_equal pr.data[:created_at].to_time, metric.created_at
    assert_equal :open_pull_request, metric.metric_action
    assert_nil metric.track
    assert_equal author, metric.user
  end

  test "adds open metric for pr with unknown author" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'

    data = {
      repo: "exercism/ruby",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: "unknown",
      merged: true,
      merged_by_username: "ErikSchierboom",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      data[:node_id],
      **data.merge(data:)
    )

    perform_enqueued_jobs

    assert_equal 1, Metric.where(metric_action: :open_pull_request).count
    metric = Metric.where(metric_action: :open_pull_request).last
    assert_equal pr.data[:created_at].to_time, metric.created_at
    assert_equal :open_pull_request, metric.metric_action
    assert_equal track, metric.track
    assert_nil metric.user
  end

  test "adds merge metric for track pr" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'
    merged_by = create :user, github_username: 'ErikSchierboom'

    data = {
      repo: "exercism/ruby",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: "iHiD",
      merged: true,
      merged_by_username: "ErikSchierboom",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      data[:node_id],
      **data.merge(data:)
    )

    perform_enqueued_jobs

    assert_equal 1, Metric.where(metric_action: :merge_pull_request).count
    metric = Metric.where(metric_action: :merge_pull_request).last
    assert_equal pr.data[:merged_at].to_time, metric.created_at
    assert_equal :merge_pull_request, metric.metric_action
    assert_equal track, metric.track
    assert_equal merged_by, metric.user
  end

  test "adds merge metric for non-track pr" do
    merged_by = create :user, github_username: 'ErikSchierboom'

    data = {
      repo: "exercism/configlet",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: "iHiD",
      merged: true,
      merged_by_username: "ErikSchierboom",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      data[:node_id],
      **data.merge(data:)
    )

    perform_enqueued_jobs

    assert_equal 1, Metric.where(metric_action: :merge_pull_request).count
    metric = Metric.where(metric_action: :merge_pull_request).last
    assert_equal pr.data[:merged_at].to_time, metric.created_at
    assert_equal :merge_pull_request, metric.metric_action
    assert_nil metric.track
    assert_equal merged_by, metric.user
  end

  test "adds merge metric for pr with unknown author" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'

    data = {
      repo: "exercism/ruby",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: "unknown",
      merged: true,
      merged_by_username: "ErikSchierboom",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      data[:node_id],
      **data.merge(data:)
    )

    perform_enqueued_jobs

    assert_equal 1, Metric.where(metric_action: :merge_pull_request).count
    metric = Metric.where(metric_action: :merge_pull_request).last
    assert_equal pr.data[:merged_at].to_time, metric.created_at
    assert_equal :merge_pull_request, metric.metric_action
    assert_equal track, metric.track
    assert_nil metric.user
  end

  test "adds merge metric for pr with merged status changing" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'
    merged_by = create :user, github_username: 'ErikSchierboom'

    data = {
      repo: "exercism/ruby",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: "iHiD",
      merged: false,
      merged_by_username: nil,
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      merged_at: nil
    }

    Github::PullRequest::CreateOrUpdate.(data[:node_id], **data.merge(data:))
    perform_enqueued_jobs

    new_data = {
      repo: "exercism/ruby",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      metric_action: "closed",
      author_username: "iHiD",
      merged: true,
      merged_by_username: "ErikSchierboom",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      merged_at: Time.parse("2020-10-17T02:39:37Z").utc
    }

    pr = Github::PullRequest::CreateOrUpdate.(
      new_data[:node_id],
      **new_data.merge(data: new_data)
    )
    perform_enqueued_jobs

    assert_equal 1, Metric.where(metric_action: :merge_pull_request).count
    metric = Metric.where(metric_action: :merge_pull_request).last
    assert_equal pr.data[:merged_at].to_time, metric.created_at
    assert_equal :merge_pull_request, metric.metric_action
    assert_equal track, metric.track
    assert_equal merged_by, metric.user
  end

  test "does not add metrics for updated pr" do
    pr = create :github_pull_request

    perform_enqueued_jobs do
      5.times do
        Github::PullRequest::CreateOrUpdate.(
          pr.node_id,
          number: pr.number,
          author_username: pr.author_username,
          merged_by_username: pr.merged_by_username,
          repo: pr.repo,
          reviews: [],
          data: pr.data
        )
      end
    end

    refute Metric.exists?
  end
end
