class Iteration
  class TestRun
    class Init
      include Mandate

      def initialize(iteration_uuid, language_slug, exercise_slug, s3_uri)
        @job_type = :test_runner
        @iteration_uuid = iteration_uuid
        @language_slug = language_slug
        @exercise_slug = exercise_slug
        @s3_uri = s3_uri
      end

      def call
        ToolingJob::Create.(
          job_type,
          iteration_uuid: iteration_uuid,
          language: language_slug,
          exercise: exercise_slug,
          s3_uri: s3_uri
        )
      end

      private
      attr_reader :job_type, :iteration_uuid, :language_slug, :exercise_slug, :s3_uri
    end
  end
end
