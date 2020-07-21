class Iteration
  class Representation
    class Init
      include Mandate

      def initialize(iteration_uuid, language_slug, exercise_slug, s3_uri, version_slug = nil)
        @iteration_uuid = iteration_uuid
        @language_slug = language_slug
        @exercise_slug = exercise_slug
        @s3_uri = s3_uri
        @version_slug = version_slug
      end

      def call
        RestClient.post "#{orchestrator_url}/jobs", {
          job_type: :representer,
          iteration_uuid: iteration_uuid,
          language: language_slug,
          exercise: exercise_slug,
          s3_uri: s3_uri,
          container_version: version_slug
        }
      end

      private
      attr_reader :iteration_uuid, :language_slug, :exercise_slug, :s3_uri, :version_slug

      def orchestrator_url
        Exercism.config.representer_orchestrator_url
      end
    end
  end
end
