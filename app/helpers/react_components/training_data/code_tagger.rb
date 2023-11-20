module ReactComponents
  module TrainingData
    class CodeTagger < ReactComponent
      include Mandate

      initialize_with :sample

      def to_s
        super("training-data-code-tagger", {
          code: {
            track: {
              title: track.title,
              icon_url: track.icon_url,
              highlightjs_language: track.highlightjs_language,
              tags:
            },
            exercise: {
              title: exercise.title,
              icon_url: exercise.icon_url
            },
            files: sample.files.map do |file|
              { filename: file['filename'], content: file['code'], type: 'readonly' }
            end
          },
          links: {
            confirm_tags_api: Exercism::Routes.update_tags_api_training_data_code_tags_sample_path(sample.uuid),
            next_sample: Exercism::Routes.next_training_data_code_tags_samples_path(track:, status: sample.status),
            training_data_dashboard: Exercism::Routes.training_data_root_path
          },
          sample: {
            status: sample.status,
            tags: sample.tags
          }
        })
      end

      private
      delegate :track, :exercise, to: :sample

      def tags = track.analyzer_tags.enabled.order(:tag).pluck(:tag)
    end
  end
end
