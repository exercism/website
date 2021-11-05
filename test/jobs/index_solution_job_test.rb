require "test_helper"

class IndexSolutionJobTest < ActiveJob::TestCase
  test "solution is indexed" do
    solution = create :practice_solution
    Solution::Index.expects(:call).with(solution)

    IndexSolutionJob.perform_now(solution)
  end
end
