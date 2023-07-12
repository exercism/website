class Exercise::QueueSolutionHeadTestRuns
  include Mandate

  queue_as :default

  initialize_with :exercise

  def call
    exercise.solutions.published.find_each do |solution|
      # This is n+2 hell.
      Solution::QueueHeadTestRun.(solution)
    end
  end
end
