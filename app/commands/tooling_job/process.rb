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

    def process_representer_job!
      Submission::Representation::Process.(job)
    end

    def process_analyzer_job!
      Submission::Analysis::Process.(job)
    end

    memoize
    def job
      # Strong consistency can take up to a second to resolve
      # If getting the tooling job fails, then let's wait for
      # half a second then try again, until 2s have passed
      loop.with_index do |_, attempt|
        return ToolingJob.find(id, full: true, strongly_consistent: true)
      rescue StandardError
        raise if attempt >= 4

        sleep(0.5)
      end
    end
  end
end
