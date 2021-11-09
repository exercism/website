class SyncSolutionToSearchIndexJob < ApplicationJob
  queue_as :default

  def perform(solution)
    Solution::SyncToSearchIndex.(solution)
  end
end
