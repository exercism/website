class QueueSolutionHeadTestRunsJob < ApplicationJob
  queue_as :default

  def perform(exercise)
    # Exercise::QueueSolutionHeadTestRuns.(exercise)
  end
end
