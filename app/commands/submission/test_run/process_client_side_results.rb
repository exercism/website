class Submission::TestRun::ProcessClientSideResults
  include Mandate

  initialize_with :submission, :test_results_json

  def call
    Submission::TestRun::Process.(
      FauxToolingJob.new(submission, test_results_json)
    )
  end

  # Rather than rewrite this critical component, for now
  # we're just stubbing a tooling job as if it had come back
  # from the server.
  class FauxToolingJob
    include Mandate

    initialize_with :submission, :test_results_json do
      @id = SecureRandom.uuid
    end

    attr_reader :id

    delegate :uuid, to: :submission, prefix: true
    def execution_status = 200
    def source = { "exercise_git_sha" => submission.solution.git_sha }
    def execution_output = { "results.json" => test_results_json }
  end
end
