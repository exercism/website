class IndexSolutionJob < ApplicationJob
  queue_as :default

  def perform(solution)
    Solution::Index.(solution)
  end
end
