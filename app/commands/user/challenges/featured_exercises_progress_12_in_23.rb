class User::Challenges::FeaturedExercisesProgress12In23
  include Mandate

  initialize_with :user

  def call
    featured_exercises.filter_map do |exercise_slug, track_slugs|
      next unless solutions.key?(exercise_slug)

      solved_in_featured_tracks = solutions[exercise_slug].select { |track_slug| track_slugs.include?(track_slug) }

      solved_in_23 = solved_in_featured_tracks.select { |_, year| year == 2023 }
      next [solved_in_23.keys.first, exercise_slug] if solved_in_23.any?

      solved_before_23 = solved_in_featured_tracks.select { |_, year| year < 2023 }
      next [solved_before_23.keys.first, exercise_slug] if solved_before_23.size == track_slugs.size
    end
  end

  private
  memoize
  def solutions
    user.solutions.published.
      joins(:track).
      pluck('exercises.slug', 'tracks.slug', 'solutions.published_at').
      group_by(&:first).
      transform_values { |solutions| solutions.map { |solution| [solution[1], solution[2].year] }.to_h }
  end

  memoize
  def featured_exercises
    (
      FEBRUARY_EXERCISES.map { |e| [e, FEBRUARY_TRACKS] } +
      MARCH_EXERCISES.map { |e| [e, MARCH_TRACKS] } +
      APRIL_EXERCISES.map { |e| [e, APRIL_TRACKS] } +
      MAY_EXERCISES.map { |e| [e, MAY_TRACKS] } +
      JUNE_EXERCISES.map { |e| [e, JUNE_TRACKS] }
    ).to_h
  end

  FEBRUARY_TRACKS = %w[clojure elixir erlang fsharp haskell ocaml scala sml gleam].freeze
  FEBRUARY_EXERCISES = %w[hamming collatz-conjecture robot-simulator yacht protein-translation].freeze

  MARCH_TRACKS = %w[c cpp d nim go rust vlang zig].freeze
  MARCH_EXERCISES = %w[linked-list simple-linked-list secret-handshake sieve binary-search pangram].freeze

  APRIL_TRACKS = %w[julia python r].freeze
  APRIL_EXERCISES = %w[etl largest-series-product saddle-points sum-of-multiples word-count].freeze

  MAY_TRACKS = %w[ballerina pharo-smalltalk prolog red rust tcl unison].freeze
  MAY_EXERCISES = %w[raindrops isogram roman-numerals space-age acronym].freeze

  JUNE_TRACKS = %w[clojure clojurescript common-lisp emacs-lisp racket scheme].freeze
  JUNE_EXERCISES = %w[leap two-fer difference-of-squares robot-name matching-brackets].freeze
end
