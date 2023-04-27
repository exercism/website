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

    # It's much quicker to get solutions via the track's exercises than an
    # exercise list generated from serialize exercises above, and it doesn't
    # matter if we have extra solutions here as we iterated over exercises, not solutions.
    SerializeSolutions.(user.solutions.where(exercise: user_track.track.exercises), user)
  end

  memoize
  def user_track
    UserTrack.for(user, track)
  end
end
