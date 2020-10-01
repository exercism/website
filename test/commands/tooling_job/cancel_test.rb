require 'test_helper'

class ToolingJob::CancelTest < ActiveSupport::TestCase
  test "cancels iteration" do
    iteration = create_iteration

    RestClient.expects(:post).with("#{Exercism.config.tooling_orchestrator_url}/iterations/cancel",
                                   iteration_uuid: iteration.uuid)

    ToolingJob::Cancel.(iteration.uuid)
  end

  test "set analysis status to cancelled" do
    iteration = create_iteration

    ToolingJob::Cancel.(iteration.uuid)

    assert iteration.reload.analysis_cancelled?
  end

  test "set representation status to cancelled" do
    iteration = create_iteration

    ToolingJob::Cancel.(iteration.uuid)

    assert iteration.reload.representation_cancelled?
  end

  private
  def create_iteration
    files = []
    solution = create :concept_solution
    Iteration::Create.(solution, files, :cli)
  end
end
