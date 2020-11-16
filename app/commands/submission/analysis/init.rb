class Submission
  class Analysis
    class Init
      include Mandate

      initialize_with :job_id, :submission_uuid, :language_slug, :exercise_slug

      def call
        ToolingJob::Create.(
          job_id,
          :analyzer,
          submission_uuid: submission_uuid,
          language: language_slug,
          exercise: exercise_slug
        )
      end
    end
  end
end
