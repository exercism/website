class User::Challenges::FeaturedExercisesProgress48In24
  include Mandate

  initialize_with :user

  EXERCISES = [
    { week: 3, slug: 'hello-world', featured_tracks: %w[python csharp javascript] },
    { week: 4, slug: 'leap', featured_tracks: %w[haskell clojure zig] }
  ].freeze

  def call
    EXERCISES.map do |exercise|
      exercise.merge({
        iterated_tracks: iterations[exercise[:slug]].to_a.map(&:first),
        status: status(exercise)
      })
    end
  end

  def status(exercise)
    iterated_exercises = iterations[exercise[:slug]].to_a
    return :in_progress if iterated_exercises.blank?

    iterated_tracks = iterated_exercises.map(&:first)
    return :gold if (exercise[:featured_tracks] - iterated_tracks).empty?

    iterated_years = iterated_exercises.map(&:second).tally
    return :silver if iterated_years[2024] >= 3
    return :bronze if iterated_years[2024].positive?

    :in_progress
  end

  private
  memoize
  def iterations
    user.solutions.
      joins(exercise: :track).
      where(exercise: { slug: EXERCISES.pluck(:slug) }).
      pluck('exercise.slug', 'tracks.slug', 'YEAR(last_iterated_at)').
      group_by(&:first).
      transform_values { |entries| entries.map { |entry| entry[1..] } }
  end
end
