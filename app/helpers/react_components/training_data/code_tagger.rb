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
              tags: enabled_track_tags
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
            confirm_tags_api: Exercism::Routes.update_tags_api_training_data_code_tags_sample_path(sample.id),
            next_sample: Exercism::Routes.next_training_data_code_tags_samples_path(track_id: track.id, status: sample.status),
            training_data_dashboard: Exercism::Routes.training_data_root_path
          },
          sample: {
            status: sample.status,
            tags: sample.tags
          }
        })
      end

      delegate :track, :exercise, to: :sample

      def enabled_track_tags
        ::Track::Tag.enabled.order(:tag).map { |tag_object| tag_object[:tag] }
      end
    end
  end
end
