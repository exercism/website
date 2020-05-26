require 'test_helper'

class IterationTest < ActiveSupport::TestCase
  test "statuses start at pending" do
    iteration = create :iteration
    assert iteration.tests_pending?
    assert iteration.representation_pending?
    assert iteration.analysis_pending?
  end

  test "iterations get their solution's git data" do
    solution = create :concept_solution
    iteration = create :iteration, solution: solution

    assert_equal solution.git_sha, iteration.git_sha
    assert_equal solution.git_slug, iteration.git_slug
  end

  test "exercise_version" do
    iteration = create :iteration
    assert_equal '15.8.12', iteration.exercise_version
  end
end
