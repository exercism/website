class User::Challenges::FeaturedExercisesProgress48In24
  include Mandate

  initialize_with :user

  # rubocop:disable Layout/LineLength
  EXERCISES = [
    { week: 1, slug: 'leap', title: "Leap", featured_tracks: %w[haskell clojure zig], learning_opportunity: "This is a relatively simple exercise, but can teach you a lot about how to write idiomatic code in a language. Should you use boolean logic, early returns, pattern matching, or something more language specific? Whatever you do, just don't use the built-in leap-year method!" },
    { week: 2, slug: 'hello-world', title: "Hello, World!", featured_tracks: %w[python csharp javascript], learning_opportunity: "" }
  ].freeze
  # rubocop:enable Layout/LineLength

  def call = EXERCISES.map { |exercise| exercise_progress(exercise) }

  private
  def exercise_progress(exercise)
    FeaturedExercise.new(
      **exercise.merge({
        exercise: csharp_exercises[exercise[:slug]],
        iterated_tracks: iterations[exercise[:slug]].to_h,
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
    iterated_featured_tracks ? :gold : :silver
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

  def csharp_exercises
    Track.find('csharp').practice_exercises.index_by(&:slug)
  rescue ActiveRecord::RecordNotFound
    {}
  end

  FeaturedExercise = Struct.new(
    :week, :slug, :title, :featured_tracks, :iterated_tracks, :status, :learning_opportunity, :exercise,
    keyword_init: true
  ) do
    delegate :title, :icon_url, :blurb, to: :exercise
  end
end
