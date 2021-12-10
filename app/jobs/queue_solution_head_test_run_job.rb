class QueueSolutionHeadTestRunJob < ApplicationJob
  queue_as :default

  def perform(solution)
    Solution::QueueHeadTestRun.(solution)
  end
end
