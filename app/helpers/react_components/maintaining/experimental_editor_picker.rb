module ReactComponents
  module Maintaining
    class ExperimentalEditorPicker < ReactComponent
      initialize_with :tracks

      def to_s
        super("maintaining-experimental-editor-picker", { tracks: tracks.map { |track| track_data(track) } })
      end

      private
      def track_data(track)
        {
          slug: track.slug,
          title: track.title,
          icon_url: track.icon_url,
          exercises: track.exercises.sort_by(&:title).map do |exercise|
            {
              slug: exercise.slug,
              title: exercise.title,
              icon_url: exercise.icon_url,
              url: Exercism::Routes.admin_experimental_editor_path(track.slug, exercise.slug)
            }
          end
        }
      end
    end
  end
end
