class Iteration
  class Analysis
    class Init
      include Mandate

      initialize_with :iteration_uuid, :language_slug, :exercise_slug, :s3_uri

      def call
        ToolingJob::Create.(
          :analyzer,
          iteration_uuid: iteration_uuid,
          language: language_slug,
          exercise: exercise_slug,
          s3_uri: s3_uri
        )
      end
    end
  end
end
