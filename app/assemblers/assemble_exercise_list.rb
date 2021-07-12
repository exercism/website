class AssembleExerciseList
  include Mandate

  initialize_with :current_user, :track, :params

  def call
    {
      exercises: SerializeExercises.(exercises, user_track: user_track),
      solutions: sideload?(:solutions) ? solutions : nil
    }.compact
  end

  def sideload?(item)
    return false unless params[:sideload]

    params[:sideload].include?(item.to_s)
  end

  memoize
  def exercises
    Exercise::Search.(track, user_track: user_track, criteria: params[:criteria])
  end

  memoize
  def user_track
    UserTrack.for(current_user, track)
  end

  memoize
  def solutions
    current_user ? SerializeSolutions.(current_user.solutions.where(exercise_id: exercises), current_user) : []
  end
end
