require 'test_helper'

class Solution::UpdateNumLocTest < ActiveSupport::TestCase
  test "set solution num_loc to latest published iteration's num_loc when present" do
    solution = create :concept_solution, num_loc: 0
    published_iteration = create :iteration, solution:, num_loc: 5
    solution.update(published_iteration:, published_at: Time.current)
    create :iteration, solution:, num_loc: 7

    Solution::UpdateNumLoc.(solution)

    assert_equal published_iteration.num_loc, solution.num_loc
  end

  test "set solution num_loc to latest iteration's num_loc when no iterations are published" do
    solution = create :concept_solution, num_loc: 0
    create :iteration, solution:, num_loc: 5
    last_iteration = create :iteration, solution:, num_loc: 8
    solution.update(published_iteration: nil, published_at: nil)

    Solution::UpdateNumLoc.(solution)

    assert_equal last_iteration.num_loc, solution.num_loc
  end

  test "set solution num_loc to 0 when there are no active iterations" do
    solution = create :concept_solution, num_loc: 2
    create :iteration, :deleted, solution:, num_loc: 5
    create :iteration, :deleted, solution:, num_loc: 8
    solution.update(published_iteration: nil, published_at: nil)

    Solution::UpdateNumLoc.(solution)

    assert_equal 0, solution.num_loc
  end

  test "resync solution to search index when set as oldest solution of exercise representation" do
    exercise = create :concept_exercise
    oldest_solution = create(:concept_solution, exercise:, num_loc: 2)
    create :iteration, solution: oldest_solution, num_loc: 5
    representation = create :exercise_representation, exercise:, oldest_solution_id: oldest_solution.id

    Exercise::Representation::SyncToSearchIndex.expects(:defer).with(representation)

    Solution::UpdateNumLoc.(oldest_solution)
  end
end
