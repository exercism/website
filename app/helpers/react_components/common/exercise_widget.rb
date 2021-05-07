module ReactComponents
  module Common
    class ExerciseWidget < ReactComponent
      def initialize(exercise, user_track,
                     solution: nil,
                     with_tooltip: false,
                     render_as_link: true,
                     render_blurb: true,
                     render_track: true,
                     skinny: false)
        super()

        @exercise = exercise
        @user_track = user_track
        @solution = solution
        @with_tooltip = with_tooltip
        @render_as_link = render_as_link
        @render_blurb = render_blurb
        @render_track = render_track
        @skinny = skinny
      end

      def to_s
        super("common-exercise-widget", {
          exercise: SerializeExercise.(exercise, user_track: user_track),
          track: render_track ? SerializeTrack.(exercise.track, user_track) : nil,
          solution: solution ? SerializeSolution.(solution, user_track: user_track) : nil,
          links: links,
          render_as_link: render_as_link,
          render_blurb: render_blurb,
          skinny: skinny
        })
      end

      private
      attr_reader :exercise, :user_track, :solution, :with_tooltip, :render_as_link, :render_blurb, :render_track, :skinny

      def links
        {
          tooltip: with_tooltip ? Exercism::Routes.tooltip_track_exercise_path(exercise.track, exercise) : nil
        }.compact
      end
    end
  end
end
