class QueueSolutionHeadTestRunsJob < ApplicationJob
  queue_as :default

  def perform(exercise)
    Exercise::MarkSolutionsAsOutOfDateInIndex.(exercise)
    Exercise::QueueSolutionHeadTestRuns.(exercise)
  end
end
