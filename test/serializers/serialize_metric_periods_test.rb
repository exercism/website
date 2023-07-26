require 'test_helper'

class SerializeMetricPeriodsTest < ActiveSupport::TestCase
  test "serialize metric periods" do
    track = create :track, slug: 'ruby'
    create(:metric_period_day, metric_type: Metrics::OpenIssueMetric.name, day: 2, count: 13, track:)
    create(:metric_period_day, metric_type: Metrics::RequestMentoringMetric.name, day: 4, count: 2, track:)
    create :metric_period_day, metric_type: Metrics::StartSolutionMetric.name, day: 28, count: 0, track: nil

    expected = [
      { count: 13, track_slug: 'ruby', type: 'open_issue_metric', "day" => 2 },
      { count: 2, track_slug: 'ruby', type: 'request_mentoring_metric', "day" => 4 },
      { count: 0, track_slug: nil, type: 'start_solution_metric', "day" => 28 }
    ]
    assert_equal expected, SerializeMetricPeriods.(MetricPeriod::Day.all)
  end
end
