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

    # TODO: It's *MUCH* quicker to get all the exercises for the user and the track
    # and then to filter out the ones we don't want, than it is to use IN (...) with ids.
    # So refactor this to do that. And check for other places too.
    SerializeSolutions.(user.solutions.where(exercise_id: exercises), user)
  end

  memoize
  def user_track
    UserTrack.for(user, track)
  end
end
