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
end
