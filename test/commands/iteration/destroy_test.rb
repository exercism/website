require 'test_helper'

class Iteration::DestroyTest < ActiveSupport::TestCase
  test "marks as deleted" do
    iteration = create :iteration

    Iteration::Destroy.(iteration)

    assert iteration.deleted?
  end

  test "unpublishes solution if iteration was published iteration" do
    iteration = create :iteration
    iteration.solution.update!(published_iteration: iteration, published_at: Time.current)

    Iteration::Destroy.(iteration)

    assert iteration.deleted?
    assert_nil iteration.solution.published_iteration
    assert_nil iteration.solution.published_at
  end

  test "unpublishes solution if iteration was not published iteration" do
    iteration = create :iteration
    iteration.solution.update!(published_iteration: iteration, published_at: Time.current)

    Iteration::Destroy.(iteration)

    assert iteration.deleted?
    assert_nil iteration.solution.published_iteration
    assert_nil iteration.solution.published_at
  end

  test "unpublishes solution if iteration was not published iteration but only deleted iterations remain" do
    iteration = create :iteration
    create :iteration, solution: iteration.solution, deleted_at: Time.current
    create :iteration, solution: iteration.solution, deleted_at: Time.current

    Iteration::Destroy.(iteration)

    assert iteration.deleted?
    assert_nil iteration.solution.published_iteration
    assert_nil iteration.solution.published_at
  end

  test "does not unpublish solution if iteration was not published iteration and non-deleted iterations remain" do
    freeze_time do
      iteration = create :iteration
      published_iteration = create :iteration, solution: iteration.solution
      published_iteration.solution.update!(published_iteration:, published_at: Time.current)

      Iteration::Destroy.(iteration)

      assert iteration.deleted?
      assert_equal published_iteration, iteration.solution.published_iteration
      assert_equal Time.current, iteration.solution.published_at
    end
  end

  test "uncompletes solution if deleted iteration was only iteration" do
    iteration = create :iteration
    iteration.solution.update!(published_iteration: iteration, published_at: Time.current, completed_at: Time.current)

    Iteration::Destroy.(iteration)

    assert_nil iteration.solution.completed_at
  end

  test "uncompletes solution if only deleted iterations remain" do
    iteration = create :iteration
    create :iteration, solution: iteration.solution, deleted_at: Time.current
    create :iteration, solution: iteration.solution, deleted_at: Time.current
    iteration.solution.update!(published_iteration: iteration, published_at: Time.current, completed_at: Time.current)

    Iteration::Destroy.(iteration)

    assert_nil iteration.solution.completed_at
  end

  test "does not uncomplete solution if a non-deleted iteration remains" do
    freeze_time do
      iteration = create :iteration
      create :iteration, solution: iteration.solution, deleted_at: Time.current
      create :iteration, solution: iteration.solution # non-deleted iteration
      iteration.solution.update!(published_iteration: iteration, published_at: Time.current, completed_at: Time.current)

      Iteration::Destroy.(iteration)

      assert_equal Time.current, iteration.solution.completed_at
    end
  end

  test "does not update solution num_loc if iteration was not published iteration" do
    solution = create :concept_solution
    iteration_1 = create :iteration, solution:, num_loc: 13
    iteration_2 = create :iteration, solution:, num_loc: 77
    solution.update!(num_loc: iteration_1.num_loc, published_iteration: iteration_1, published_at: Time.current)

    Iteration::Destroy.(iteration_2)

    assert_equal iteration_1.num_loc, solution.num_loc
  end

  test "updates solution num_loc to latest active iteration if iteration was published iteration" do
    solution = create :concept_solution
    iteration_1 = create :iteration, solution:, num_loc: 13
    iteration_2 = create :iteration, solution:, num_loc: 77
    solution.update!(num_loc: iteration_1.num_loc, published_iteration: iteration_1, published_at: Time.current)

    Iteration::Destroy.(iteration_1)

    assert_equal iteration_2.num_loc, solution.num_loc
  end

  test "updates solution num_loc to latest active iteration if no iteration was published" do
    solution = create :concept_solution
    iteration_1 = create :iteration, solution:, num_loc: 13
    iteration_2 = create :iteration, solution:, num_loc: 77
    solution.update!(num_loc: iteration_1.num_loc)

    Iteration::Destroy.(iteration_1)

    assert_equal iteration_2.num_loc, solution.num_loc
  end

  test "updates solution num_loc to zero if there are no active iterations" do
    solution = create :concept_solution
    iteration_1 = create :iteration, solution:, num_loc: 13
    create :iteration, :deleted, solution:, num_loc: 77
    solution.update!(num_loc: iteration_1.num_loc)

    Iteration::Destroy.(iteration_1)

    assert_equal 0, solution.num_loc
  end

  test "updates snippet on previous iteration if doesn't exist" do
    solution = create :concept_solution, :published
    iteration_1 = create(:iteration, solution:)
    iteration_2 = create(:iteration, solution:)

    Iteration::GenerateSnippet.expects(:defer).with(iteration_1)
    Iteration::Destroy.(iteration_2)
  end

  test "updates snippet on solution if prev iteration snippet exists" do
    solution = create :concept_solution, :published
    create(:iteration, solution:, snippet: "foobar")
    iteration_2 = create(:iteration, solution:)

    Solution::UpdateSnippet.expects(:call).with(solution)
    Iteration::Destroy.(iteration_2)
  end
end
