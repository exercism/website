require "test_helper"

class Metric::CreateTest < ActiveSupport::TestCase
  test "creates metric" do
    freeze_time do
      occurred_at = Time.current - 2.seconds
      solution = create :concept_solution
      track = solution.track
      user = solution.user

      Metric::Create.(:start_solution, occurred_at, track:, user:, solution:)

      assert_equal 1, Metric.count
      metric = Metric.last

      assert_equal occurred_at, metric.occurred_at
      assert_equal Time.current, metric.created_at
      assert_equal Time.current, metric.updated_at
      assert_equal track, metric.track
      assert_equal user, metric.user
    end
  end

  test "stores the visitor location from the request context" do
    solution = create :concept_solution
    track = solution.track
    user = solution.user

    request_context = { country_code: 'NL', coordinates: [52.3676, 4.9041] }

    Metric::Create.(:start_solution, Time.current, track:, user:, solution:, request_context:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal 'NL', metric.country_code
    assert_equal 'Netherlands', metric.country_name
    assert_equal [52.3676, 4.9041], metric.coordinates
  end

  test "creates metric with no request context" do
    solution = create :concept_solution
    track = solution.track
    user = solution.user

    Metric::Create.(:start_solution, Time.current, track:, user:, solution:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_nil metric.country_code
    assert_nil metric.country_name
    assert_nil metric.coordinates
  end

  test "creates metric with an unknown country code" do
    action = :start_solution
    solution = create :concept_solution
    occurred_at = Time.current - 2.seconds
    request_context = { country_code: nil, coordinates: nil }

    Metric::Create.(action, occurred_at, solution:, request_context:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal occurred_at, metric.occurred_at
    assert_nil metric.country_code
    assert_nil metric.country_name
    assert_nil metric.coordinates
  end

  test "creates metric that does not use remote ip" do
    action = :open_issue
    issue = create :github_issue
    occurred_at = Time.current - 2.seconds

    Metric::Create.(action, occurred_at, issue:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal occurred_at, metric.occurred_at
    assert_nil metric.country_code
  end

  test "sets country code to nil if country code is empty string" do
    solution = create :concept_solution
    track = solution.track
    user = solution.user

    request_context = { country_code: '' }

    Metric::Create.(:start_solution, Time.current, track:, user:, solution:, request_context:)

    assert_equal 1, Metric.count
    assert_nil Metric.last.country_code
    assert_nil Metric.last.country_name
  end

  test "creates metric without track or user" do
    action = :start_solution
    solution = create :concept_solution
    occurred_at = Time.current - 2.seconds

    Metric::Create.(action, occurred_at, solution:)

    assert_equal 1, Metric.count
    metric = Metric.last

    assert_equal occurred_at, metric.occurred_at
    assert_nil metric.track
    assert_nil metric.user
  end

  test "broadcasts metric" do
    action = :start_solution
    solution = create :concept_solution
    occurred_at = Time.current - 2.seconds

    MetricsChannel.expects(:broadcast!).with do |metric|
      assert metric.is_a?(Metrics::StartSolutionMetric)
    end

    Metric::Create.(action, occurred_at, solution:)
  end
end
