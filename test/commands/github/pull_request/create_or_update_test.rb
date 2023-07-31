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
      action: "closed",
      author_username: "iHiD",
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
      action: "closed",
      author_username: "iHiD",
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

  test "adds open metric when pull request is created for track repo" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'
    author = create :user, github_username: 'iHiD'

    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo: "exercism/ruby",
      title: "A fine PR",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      action: "closed",
      author_username: author.github_username,
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      labels: [],
      merged: true,
      merged_by_username: "ErikSchierboom",
      reviews: [],
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    perform_enqueued_jobs do
      Github::PullRequest::CreateOrUpdate.(
        data[:node_id], **data.slice(:number, :title, :state, :author_username, :merged_by_username, :repo, :reviews).merge(data:)
      )
    end

    assert_equal 1, Metric.where(type: Metrics::OpenPullRequestMetric.name).count
    metric = Metric.where(type: Metrics::OpenPullRequestMetric.name).last
    assert_instance_of Metrics::OpenPullRequestMetric, metric
    assert_equal data[:created_at].to_time, metric.occurred_at
    assert_equal track, metric.track
    assert_equal author, metric.user
  end

  test "adds open metric when pull request is created for non-track repo" do
    author = create :user, github_username: 'iHiD'

    data = {
      url: "https://api.github.com/repos/exercism/configlet/pulls/2",
      repo: "exercism/configlet",
      title: "A fine PR",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      action: "closed",
      author_username: author.github_username,
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      labels: [],
      merged: true,
      merged_by_username: "ErikSchierboom",
      reviews: [],
      html_url: "https://github.com/exercism/configlet/pull/2"
    }

    perform_enqueued_jobs do
      Github::PullRequest::CreateOrUpdate.(
        data[:node_id], **data.slice(:number, :title, :state, :author_username, :merged_by_username, :repo, :reviews).merge(data:)
      )
    end

    assert_equal 1, Metric.where(type: Metrics::OpenPullRequestMetric.name).count
    metric = Metric.where(type: Metrics::OpenPullRequestMetric.name).last
    assert_equal data[:created_at].to_time, metric.occurred_at
    assert_instance_of Metrics::OpenPullRequestMetric, metric
    assert_nil metric.track
    assert_equal author, metric.user
  end

  test "adds open metric when pull request is created with unknown author" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'

    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo: "exercism/ruby",
      title: "A fine PR",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "closed",
      action: "closed",
      author_username: "unknown",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      labels: [],
      merged: true,
      merged_by_username: "ErikSchierboom",
      reviews: [],
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    perform_enqueued_jobs do
      Github::PullRequest::CreateOrUpdate.(
        data[:node_id], **data.slice(:number, :title, :state, :author_username, :merged_by_username, :repo, :reviews).merge(data:)
      )
    end

    assert_equal 1, Metric.where(type: Metrics::OpenPullRequestMetric.name).count
    metric = Metric.where(type: Metrics::OpenPullRequestMetric.name).last
    assert_equal data[:created_at].to_time, metric.occurred_at
    assert_instance_of Metrics::OpenPullRequestMetric, metric
    assert_equal track, metric.track
    assert_nil metric.user
  end

  test "does not add open metric when pull request already exists" do
    pr = create :github_pull_request

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

    refute Metric.where(type: Metrics::OpenPullRequestMetric.name).exists?
  end

  test "adds merge metric when pull request is created with merged state for track repo" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'
    merged_by = create :user, github_username: 'iHiD'

    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo: "exercism/ruby",
      title: "A fine PR",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "merged",
      action: "closed",
      author_username: "iHiD",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      labels: [],
      merged: true,
      merged_at: Time.parse("2020-10-23T14:15:16Z").utc,
      merged_by_username: merged_by.github_username,
      reviews: [],
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    perform_enqueued_jobs do
      Github::PullRequest::CreateOrUpdate.(
        data[:node_id], **data.slice(:number, :title, :state, :author_username, :merged_by_username, :repo, :reviews).merge(data:)
      )
    end

    assert_equal 1, Metrics::MergePullRequestMetric.count
    metric = Metrics::MergePullRequestMetric.last
    assert_equal data[:merged_at].to_time, metric.occurred_at
    assert_instance_of Metrics::MergePullRequestMetric, metric
    assert_equal track, metric.track
    assert_equal merged_by, metric.user
  end

  test "adds merge metric when pull request is created with merged state for non-track repo" do
    merged_by = create :user, github_username: 'iHiD'

    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo: "exercism/ruby",
      title: "A fine PR",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "merged",
      action: "closed",
      author_username: "iHiD",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      labels: [],
      merged: true,
      merged_at: Time.parse("2020-10-23T14:15:16Z").utc,
      merged_by_username: merged_by.github_username,
      reviews: [],
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    perform_enqueued_jobs do
      Github::PullRequest::CreateOrUpdate.(
        data[:node_id], **data.slice(:number, :title, :state, :author_username, :merged_by_username, :repo, :reviews).merge(data:)
      )
    end

    assert_equal 1, Metrics::MergePullRequestMetric.count
    metric = Metrics::MergePullRequestMetric.last
    assert_equal data[:merged_at].to_time, metric.occurred_at
    assert_instance_of Metrics::MergePullRequestMetric, metric
    assert_nil metric.track
    assert_equal merged_by, metric.user
  end

  test "adds merge metric when pull request is created with merged state and unknown author" do
    track = create :track, slug: 'ruby', repo_url: 'https://github.com/exercism/ruby'

    data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      repo: "exercism/ruby",
      title: "A fine PR",
      node_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
      number: 2,
      state: "merged",
      action: "closed",
      author_username: "unknown",
      created_at: Time.parse("2020-10-17T02:39:37Z").utc,
      labels: [],
      merged: true,
      merged_at: Time.parse("2020-10-23T14:15:16Z").utc,
      merged_by_username: "ErikSchierboom",
      reviews: [],
      html_url: "https://github.com/exercism/ruby/pull/2"
    }

    perform_enqueued_jobs do
      Github::PullRequest::CreateOrUpdate.(
        data[:node_id], **data.slice(:number, :title, :state, :author_username, :merged_by_username, :repo, :reviews).merge(data:)
      )
    end

    assert_equal 1, Metrics::MergePullRequestMetric.count
    metric = Metrics::MergePullRequestMetric.last
    assert_equal data[:merged_at].to_time, metric.occurred_at
    assert_instance_of Metrics::MergePullRequestMetric, metric
    assert_equal track, metric.track
    assert_nil metric.user
  end

  %i[open closed].each do |state|
    test "adds merge metric when pull request is updated and state changes from #{state} to merged" do
      pr = create(:github_pull_request, state:)
      merged_by = create :user, github_username: 'iHiD'
      merged_at = Time.parse("2020-10-23T14:15:16Z").utc

      perform_enqueued_jobs do
        Github::PullRequest::CreateOrUpdate.(
          pr.node_id,
          title: pr.title,
          number: pr.number,
          state: :merged,
          author_username: pr.author_username,
          merged_by_username: pr.merged_by_username,
          repo: pr.repo,
          reviews: pr.reviews,
          data: pr.data.merge(
            state:,
            merged_at:,
            merged_by_username: merged_by.github_username
          )
        )
      end

      assert_equal 1, Metric.where(type: Metrics::MergePullRequestMetric.name).count
      metric = Metric.where(type: Metrics::MergePullRequestMetric.name).last
      assert_equal merged_at, metric.occurred_at
      assert_instance_of Metrics::MergePullRequestMetric, metric
      assert_nil metric.track
      assert_nil metric.user
    end

    test "does not add merge metric when pull request is updated but state changes to #{state}" do
      pr = create :github_pull_request, state: :merged

      perform_enqueued_jobs do
        Github::PullRequest::CreateOrUpdate.(
          pr.node_id,
          title: pr.title,
          number: pr.number,
          state:,
          author_username: pr.author_username,
          merged_by_username: nil,
          repo: pr.repo,
          reviews: pr.reviews,
          data: pr.data
        )
      end

      refute Metric.where(type: Metrics::OpenPullRequestMetric.name).exists?
    end
  end
end
