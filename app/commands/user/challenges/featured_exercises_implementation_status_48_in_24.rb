class User::Challenges::FeaturedExercisesImplementationStatus48In24
  include Mandate

  initialize_with :featured_exercises, :tracks

  def call
    tracks.map do |track|
      exercises = featured_exercises.map do |featured_exercise|
        [featured_exercise[:slug], track_exercise_status(track, featured_exercise)]
      end.to_h

      [track.slug, exercises]
    end.to_h
  end

  private
  def track_exercise_status(track, featured_exercise)
    return :featured if featured_exercise[:featured_tracks].include?(track.slug)

    exercise_slug = featured_exercise[:slug]
    return :do_not_implement if track.foregone_exercises.include?(exercise_slug)

    case track_exercises.dig(track.slug, exercise_slug)
    when nil
      :missing
    when 'active', 'beta'
      :present
    when 'deprecated'
      :do_not_implement
    end
  end

  memoize
  def track_exercises
    Exercise.joins(:track).
      where(status: %i[beta active deprecated], track: tracks).
      where(slug: featured_exercises.pluck(:slug)).
      pluck('tracks.slug', 'exercises.slug', 'exercises.status').
      group_by(&:first).
      transform_values { |group| group.map { |values| values[1..] }.to_h }
  end
end
