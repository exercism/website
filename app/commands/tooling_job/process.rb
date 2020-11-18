class ToolingJob
  class Process
    include Mandate

    initialize_with :id

    def call
      send("process_#{job.type}_job!")
      job.processed!
    end

    private
    def process_test_runner_job!
      Submission::TestRun::Process.(job)
    end

    # TODO: Refactor this to be like test runner
    def process_representer_job!
      Submission::Representation::Process.(job)
    end

    # TODO: Refactor this to be like test runner
    def process_analyzer_job!
      Submission::Analysis::Process.(
        job.submission_uuid,
        job.execution_status,
        safe_json_parse("analysis.json")
      )
    end

    def safe_json_parse(filename)
      JSON.parse(job.execution_output[filename])
    end

    memoize
    def job
      ToolingJob.find(id, full: true)
    end
  end
end
