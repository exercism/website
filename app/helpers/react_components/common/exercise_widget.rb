module ReactComponents
  module Common
    class ExerciseWidget < ReactComponent
      def initialize(exercise, user_track,
                     solution: nil,
                     with_tooltip: false,
                     render_blurb: true,
                     render_track: true,
                     recommended: false,
                     skinny: false)
        super()

        @exercise = exercise
        @user_track = user_track
        @solution = solution
        @with_tooltip = with_tooltip
        @render_blurb = render_blurb
        @render_track = render_track
        @recommended = recommended
        @skinny = skinny
      end

      def to_s
        data = AssembleExerciseWidget.(
          exercise,
          user_track,
          solution:,
          with_tooltip:,
          render_blurb:,
          render_track:,
          recommended:,
          skinny:
        )

        super("common-exercise-widget", data)
      end

      private
      attr_reader :exercise, :user_track, :solution, :with_tooltip, :render_blurb, :render_track,
        :recommended, :skinny
    end
  end
end
