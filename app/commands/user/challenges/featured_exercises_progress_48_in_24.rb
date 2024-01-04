class User::Challenges::FeaturedExercisesProgress48In24
  include Mandate

  initialize_with :user

  EXERCISES = [
    { week: 3, slug: 'hello-world', featured_tracks: %w[python csharp javascript] },
    { week: 4, slug: 'leap', featured_tracks: %w[haskell clojure zig] }
  ].freeze

  def call = EXERCISES.map { |exercise| exercise_progress(exercise) }

  private
  def exercise_progress(exercise)
    OpenStruct.new(
      exercise.merge({
        iterated_tracks: iterations[exercise[:slug]].to_a.map(&:first),
        status: status(exercise)
      })
    )
  end

  def status(exercise)
    iterated_exercises = iterations[exercise[:slug]].to_a
    return :in_progress if iterated_exercises.blank?

    num_iterations_in_2024 = iterated_exercises.count { |(_, year)| year == 2024 }
    return :in_progress if num_iterations_in_2024.zero?
    return :bronze if num_iterations_in_2024 < 3

    iterated_featured_tracks = (exercise[:featured_tracks] - iterated_exercises.map(&:first)).empty?
    return :silver unless iterated_featured_tracks

    :gold
  end

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
