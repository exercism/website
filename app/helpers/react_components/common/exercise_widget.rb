module ReactComponents
  module Common
    class ExerciseWidget < ReactComponent
      SIZES = %i[tiny small medium large tooltip].freeze

      def initialize(exercise, user_track, size:, solution: nil)
        raise "Invalid exercise size #{size}" unless SIZES.include?(size.to_sym)

        super()

        @exercise = exercise
        @user_track = user_track
        @solution = solution
        @size = size
      end

      def to_s
        super("common-exercise-widget", {
          exercise: SerializeExercise.(exercise, user_track: user_track),
          track: SerializeTrack.(exercise.track, user_track),
          solution: solution ? SerializeSolution.(solution, user_track: user_track) : nil,
          size: size
        })
      end

      private
      attr_reader :exercise, :user_track, :solution, :size
    end
  end
end
