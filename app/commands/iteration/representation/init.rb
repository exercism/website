class Iteration
  module Representation
    class Init
      include Mandate

      def initialize(iteration_uuid, language_slug, exercise_slug, version_slug = nil)
        @iteration_uuid = iteration_uuid
        @language_slug = language_slug
        @exercise_slug = exercise_slug
        @version_slug = version_slug
      end

      def call
        RestClient.post "#{orchestrator_url}/iterations", {
          iteration_uuid: iteration_uuid,
          language_slug: language_slug,
          exercise_slug: exercise_slug,
          version_slug: version_slug
        }
      end
      
      private
      attr_reader :iteration_uuid, :language_slug, :exercise_slug, :version_slug

      def orchestrator_url
        Exercism.config.representer_orchestrator_url
      end
    end
  end

end

