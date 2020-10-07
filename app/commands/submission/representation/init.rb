class Submission
  class Representation
    class Init
      include Mandate

      initialize_with :submission_uuid, :language_slug, :exercise_slug, :s3_uri

      def call
        ToolingJob::Create.(
          :representer,
          submission_uuid: submission_uuid,
          language: language_slug,
          exercise: exercise_slug,
          s3_uri: s3_uri
        )
      end
    end
  end
end
