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
              highlightjs_language: track.highlightjs_language
            },
            exercise: {
              title: exercise.title,
              icon_url: exercise.icon_url
            },
            files: sample.files.map do |file|
              { filename: file['filename'], content: file['code'], type: 'readonly' }
            end
          },
          tags: sample.tags,
          links: {
            confirm_tags_api: '',
            next_sample: Exercism::Routes.next_training_data_code_tags_samples_path(track_id: track.id, status: sample.status),
            training_data_dashboard: ''
          },
          status: sample.status
        })
      end

      delegate :track, :exercise, to: :sample
    end
  end
end
