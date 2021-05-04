module ReactComponents
  module Common
    class ExerciseWidget < ReactComponent
      SIZES = %i[tiny small medium large tooltip].freeze

      def initialize(exercise, user_track, size:, solution: nil, with_tooltip: false)
        raise "Invalid exercise size #{size}" unless SIZES.include?(size.to_sym)

        super()

        @exercise = exercise
        @user_track = user_track
        @solution = solution
        @size = size
        @with_tooltip = with_tooltip
      end

      def to_s
        super("common-exercise-widget", {
          exercise: SerializeExercise.(exercise, user_track: user_track),
          track: SerializeTrack.(exercise.track, user_track),
          solution: solution ? SerializeSolution.(solution, user_track: user_track) : nil,
          size: size,
          links: links
        })
      end

      private
      attr_reader :exercise, :user_track, :solution, :size, :with_tooltip

      def links
        {
          tooltip: with_tooltip ? Exercism::Routes.tooltip_track_exercise_path(exercise.track, exercise) : nil
        }.compact
      end
    end
  end
end
