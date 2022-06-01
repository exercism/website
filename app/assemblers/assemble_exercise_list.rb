class AssembleExerciseList < Assembler
  include Mandate

  initialize_with :user, :track, :params

  def call
    {
      exercises: SerializeExercises.(exercises, user_track:),
      solutions: sideload?(:solutions) ? solutions : nil
    }.compact
  end

  memoize
  def exercises
    Exercise::Search.(user_track, criteria: params[:criteria])
  end

  memoize
  def solutions
    return [] unless user

    SerializeSolutions.(user.solutions.where(exercise_id: exercises), user)
  end

  memoize
  def user_track
    UserTrack.for(user, track)
  end
end
