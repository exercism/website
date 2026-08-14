require "test_helper"

class Metric::SweepTest < ActiveSupport::TestCase
  test "does nothing when the table is empty" do
    assert_equal 0, Metric.count

    Metric::Sweep.()

    assert_equal 0, Metric.count
  end

  test "does nothing when everything is inside the retention window" do
    metrics = [6.days.ago, 1.day.ago, 1.hour.ago].map { |t| create :metric, occurred_at: t }

    Metric::Sweep.()

    assert_equal metrics, Metric.order(:id).to_a
  end

  test "deletes metrics outside the retention window" do
    old = [30.days.ago, 20.days.ago, 10.days.ago].map { |t| create :metric, occurred_at: t }
    recent = [1.day.ago, 1.hour.ago].map { |t| create :metric, occurred_at: t }

    with_step(1) { Metric::Sweep.() }

    # The boundary is deliberately approximate - we stop at the last row we
    # know to be old and delete everything strictly before it, so that row
    # survives this sweep (it goes in the next one).
    assert_equal [old.last] + recent, Metric.order(:id).to_a
  end

  test "deletes a backlog spanning several steps" do
    old = Array.new(10) { |i| create :metric, occurred_at: (30 - i).days.ago }
    recent = create :metric, occurred_at: 1.hour.ago

    with_step(2) { Metric::Sweep.() }

    remaining = Metric.order(:id).to_a
    assert_includes remaining, recent
    refute_includes remaining, old.first
    # recent, plus at most STEP rows retained by the approximate boundary
    assert_operator remaining.size, :<=, 3
  end

  test "copes with gaps in the id sequence" do
    old = Array.new(6) { |i| create :metric, occurred_at: (30 - i).days.ago }
    recent = create :metric, occurred_at: 1.hour.ago

    # Introduce gaps, as rolled-back inserts do in production
    Metric.where(id: [old[1].id, old[3].id]).delete_all

    with_step(1) { Metric::Sweep.() }

    assert_equal [old.last, recent], Metric.order(:id).to_a
  end

  private
  def with_step(step)
    original = Metric::Sweep::STEP
    silence_warnings { Metric::Sweep.const_set(:STEP, step) }
    yield
  ensure
    silence_warnings { Metric::Sweep.const_set(:STEP, original) }
  end
end
