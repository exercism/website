class SerializeSiteUpdates
  include Mandate

  def initialize(updates, user: nil)
    @updates = updates
    @user = user
  end

  def call
    updates.map do |update|
      update.rendering_data.merge(update_specific_data(update))
    end
  end

  def update_specific_data(update)
    return {} unless update.expanded?

    case update
    when SiteUpdates::NewExerciseUpdate
      { exercise_widget: data_for_exercise(update) }
    else
      {}
    end
  end

  def data_for_exercise(update)
    solution = solutions[update.exercise_id]

    {
      exercise: SerializeExercise.(update.exercise),
      solution: solution ? SerializeSolution.(solution, user_track: user_tracks[update.track_id]) : nil
    }
  end

  private
  attr_reader :updates, :user

  memoize
  def user_tracks
    UserTrack.where(user: user, track_id: updates.map(&:track_id).compact).index_by(&:track_id)
  end

  def exercises
    Exercise.where(id: updates.map(&:exercise_id).compact).index_by(&:exercise_id)
  end

  def solutions
    Solution.where(user: user, exercise_id: updates.map(&:exercise_id).compact).index_by(&:exercise_id)
  end
end
