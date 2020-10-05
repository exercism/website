require 'test_helper'

class ToolingJob::CancelTest < ActiveSupport::TestCase
  test "cancels analysis job" do
    skip
    iteration = create_iteration

    # TODO: Check job has updated in dynamodb
    ToolingJob::Cancel.(iteration.uuid, :analysis)
  end

  test "set analysis status to cancelled" do
    # TODO: Fix this test
    skip

    iteration = create_iteration

    ToolingJob::Cancel.(iteration.uuid, :analysis)

    assert iteration.reload.analysis_cancelled?
  end

  test "set representation status to cancelled" do
    # TODO: Fix this test
    skip

    iteration = create_iteration

    ToolingJob::Cancel.(iteration.uuid, :representation)

    assert iteration.reload.representation_cancelled?
  end

  private
  def create_iteration
    files = []
    solution = create :concept_solution
    Iteration::Create.(solution, files, :cli)
  end
end
