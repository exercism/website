module ReactComponents
  module Common
    class ExerciseWidget < ReactComponent
      SIZES = %i[small medium large].freeze

      def initialize(exercise, user_track, size:, solution: nil, desc: true)
        raise "Invalid exercise size #{size}" unless SIZES.include?(size.to_sym)

        super()

        @exercise = exercise
        @user_track = user_track
        @solution = solution
        @size = size
        @desc = desc
      end

      def to_s
        super("common-exercise-widget", {
          exercise: SerializeExercise.(exercise, user_track: user_track),
          solution: solution,
          size: size,
          show_desc: desc
        })
      end

      private
      attr_reader :exercise, :user_track, :solution, :size, :desc
    end
  end
end
