require 'test_helper'

class Iteration::DestroyTest < ActiveSupport::TestCase
  test "marks as deleted" do
    iteration = create :iteration

    Iteration::Destroy.(iteration)

    assert iteration.deleted?
  end

  test "updates published iteration on solution" do
    iteration = create :iteration
    iteration.solution.update!(published_iteration: iteration)

    Iteration::Destroy.(iteration)

    assert iteration.deleted?
    assert_nil iteration.solution.published_iteration
  end
end
