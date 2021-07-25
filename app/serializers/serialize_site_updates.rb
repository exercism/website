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
      { exercise_widget: data_for_exercise_widget(update) }
    else
      {}
    end
  end

  def data_for_exercise_widget(update)
    AssembleExerciseWidget.(
      update.exercise,
      user_tracks[update.track_id],
      solution: solutions[update.exercise_id],
      with_tooltip: false,
      render_as_link: true,
      render_blurb: true,
      render_track: true,
      recommended: false,
      skinny: false
    )
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
