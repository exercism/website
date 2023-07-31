class SerializeExerciseAuthorships
  include Mandate

  initialize_with :exercises

  def call
    exercises.includes(:track).map do |exercise|
      user_track = UserTrack::External.new(exercise.track)

      {
        exercise: SerializeExercise.(exercise, user_track:),
        track: SerializeTrack.(exercise.track, user_track)
      }
    end
  end
end
