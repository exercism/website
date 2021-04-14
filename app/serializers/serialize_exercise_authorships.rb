class SerializeExerciseAuthorships
  include Mandate

  def initialize(exercises)
    @exercises = exercises
  end

  def call
    exercises.map do |exercise|
      user_track = UserTrack::External.new(exercise.track)

      {
        exercise: SerializeExercise.(exercise, user_track: user_track),
        track: SerializeTrack.(exercise.track, user_track)
      }
    end
  end

  private
  attr_reader :exercises, :user_track
end
