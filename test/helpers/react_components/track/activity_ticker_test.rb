require_relative "../react_component_test_case"
class ReactComponents::Track::ActivityTickerTest < ReactComponentTestCase
  test "all allowed metric types resolve to real metric classes" do
    ReactComponents::Track::ActivityTicker::ALLOWED_METRIC_TYPES.each do |type|
      klass = type.safe_constantize
      refute_nil klass, "#{type} does not exist"
      assert klass < ::Metric, "#{type} is not a Metric"
    end
  end

  test "start solution metrics are included" do
    assert_includes ReactComponents::Track::ActivityTicker::ALLOWED_METRIC_TYPES,
      Metrics::StartSolutionMetric.name
  end

  test "initial_data returns the most recent allowed metric for the track" do
    ruby = create :track
    create :join_track_metric, track: ruby # Not an allowed type
    metric = create :start_solution_metric, track: ruby

    component = ReactComponents::Track::ActivityTicker.new(ruby)

    # Coordinates are randomised when absent, so just check the identity
    assert_equal metric.id, component.initial_data[:id]
    assert_equal 'start_solution_metric', component.initial_data[:type]
  end

  test "initial_data is cached per track" do
    ruby = create :track
    original = create :start_solution_metric, track: ruby

    assert_equal original.id, ReactComponents::Track::ActivityTicker.new(ruby).initial_data[:id]

    create :start_solution_metric, track: ruby

    # The ticker picks new activity up over the MetricsChannel rather than by
    # re-reading this, so the newer metric is deliberately not reflected here.
    assert_equal original.id, ReactComponents::Track::ActivityTicker.new(ruby).initial_data[:id]
  end

  test "initial_data is not shared between tracks" do
    ruby = create :track
    js = create :track, slug: 'js'
    ruby_metric = create :start_solution_metric, track: ruby
    js_metric = create :start_solution_metric, track: js

    assert_equal ruby_metric.id, ReactComponents::Track::ActivityTicker.new(ruby).initial_data[:id]
    assert_equal js_metric.id, ReactComponents::Track::ActivityTicker.new(js).initial_data[:id]
  end

  test "initial_data ignores metrics from other tracks" do
    ruby = create :track
    js = create :track, slug: 'js'
    create :start_solution_metric, track: js

    component = ReactComponents::Track::ActivityTicker.new(ruby)

    assert_nil component.initial_data
  end
end
