require "test_helper"

class SyncSolutionToSearchIndexJobTest < ActiveJob::TestCase
  test "solution is indexed" do
    solution = create :practice_solution
    Solution::SyncToSearchIndex.expects(:call).with(solution)

    SyncSolutionToSearchIndexJob.perform_now(solution)
  end
end
