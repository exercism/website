class Exercise::QueueSolutionHeadTestRuns
  include Mandate

  initialize_with :exercise

  def initialize(exercise)
    @exercise = exercise
    @git_sha = exercise.git_sha
  end

  def call
    exercise.solutions.published.find_each do |solution|
      queue_solution(solution)
    end
  end

  def queue_solution(solution)
    # This is n+2 hell.
    submission = solution.published_iterations.last.submission
    return if submission.head_test_run

    Submission::TestRun::Init.(submission, head_run: true, git_sha: git_sha)
  end

  private
  attr_reader :exercise, :git_sha
end
