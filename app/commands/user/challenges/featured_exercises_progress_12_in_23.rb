class User::Challenges::FeaturedExercisesProgress12In23
  include Mandate

  initialize_with :user

  FEBRUARY_TRACKS = %w[clojure elixir erlang fsharp haskell ocaml scala sml gleam].freeze
  FEBRUARY_EXERCISES = %w[hamming collatz-conjecture robot-simulator yacht protein-translation].freeze

  MARCH_TRACKS = %w[c cpp d nim go rust vlang zig].freeze
  MARCH_EXERCISES = %w[linked-list simple-linked-list secret-handshake sieve binary-search pangram].freeze

  APRIL_TRACKS = %w[julia python r].freeze
  APRIL_EXERCISES = %w[etl largest-series-product saddle-points sum-of-multiples word-count].freeze

  MAY_TRACKS = %w[ballerina pharo-smalltalk prolog red rust tcl unison].freeze
  MAY_EXERCISES = %w[raindrops isogram roman-numerals space-age acronym].freeze

  JUNE_TRACKS = %w[clojure common-lisp emacs-lisp lfe racket scheme].freeze
  JUNE_EXERCISES = %w[leap two-fer difference-of-squares robot-name matching-brackets].freeze

  JULY_TRACKS = %w[c cpp cobol fortran vbnet].freeze
  JULY_EXERCISES = %w[bob allergies reverse-string high-scores armstrong-numbers].freeze

  AUGUST_TRACKS = %w[abap coffeescript dart delphi elm java javascript kotlin objective-c php purescript reasonml swift
                     typescript].freeze
  AUGUST_EXERCISES = %w[anagram phone-number triangle rna-transcription scrabble-score].freeze

  SEPTEMBER_TRACKS = %w[8th awk bash jq perl5 raku].freeze
  SEPTEMBER_EXERCISES = %w[atbash-cipher darts gigasecond luhn series].freeze

  OCTOBER_TRACKS = %w[crystal csharp java pharo-smalltalk ruby powershell].freeze
  OCTOBER_EXERCISES = %w[binary-search-tree circular-buffer clock matrix simple-cipher].freeze

  NOVEMBER_TRACKS = %w[x86-64-assembly mips wasm].freeze
  NOVEMBER_EXERCISES = %w[pop-count grains resistor-color rotational-cipher nucleotide-count].freeze

  DECEMBER_TRACKS = %w[cfml groovy lua vimscript wren].freeze
  DECEMBER_EXERCISES = %w[all-your-base flatten-array queen-attack dnd-character run-length-encoding].freeze

  def call
    exercises = self.class.featured_exercises.filter_map do |exercise_slug, track_slugs|
      next { slug: exercise_slug, earned_for: nil, track_slugs: } unless solutions.key?(exercise_slug)

      solved_in_featured_tracks = solutions[exercise_slug].select { |track_slug| track_slugs.include?(track_slug) }

      solved_in_23 = solved_in_featured_tracks.select { |_, year| year == 2023 }
      next { slug: exercise_slug, earned_for: solved_in_23.keys.first, track_slugs: } if solved_in_23.any?

      solved_before_23 = solved_in_featured_tracks.select { |_, year| year < 2023 }
      next { slug: exercise_slug, earned_for: solved_before_23.keys.first, track_slugs: } if solved_before_23.size == track_slugs.size

      { slug: exercise_slug, earned_for: nil, track_slugs: }
    end

    remove_march_duplicates(exercises)
  end

  def self.num_featured_exercises = self.featured_exercises.size - 1

  memoize
  def self.featured_exercises
    (
      FEBRUARY_EXERCISES.map { |e| [e, FEBRUARY_TRACKS] } +
      MARCH_EXERCISES.map { |e| [e, MARCH_TRACKS] } +
      APRIL_EXERCISES.map { |e| [e, APRIL_TRACKS] } +
      MAY_EXERCISES.map { |e| [e, MAY_TRACKS] } +
      JUNE_EXERCISES.map { |e| [e, JUNE_TRACKS] } +
      JULY_EXERCISES.map { |e| [e, JULY_TRACKS] } +
      AUGUST_EXERCISES.map { |e| [e, AUGUST_TRACKS] } +
      SEPTEMBER_EXERCISES.map { |e| [e, SEPTEMBER_TRACKS] } +
      OCTOBER_EXERCISES.map { |e| [e, OCTOBER_TRACKS] } +
      NOVEMBER_EXERCISES.map { |e| [e, NOVEMBER_TRACKS] } +
      DECEMBER_EXERCISES.map { |e| [e, DECEMBER_TRACKS] }
    ).to_h
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

  def remove_march_duplicates(exercises_progress)
    linked_list_exercise_progress = exercises_progress.find { |exercise_progress| exercise_progress[:slug] == 'linked-list' }
    simple_linked_list_exercise_progress = exercises_progress.find do |exercise_progress|
      exercise_progress[:slug] == 'simple-linked-list'
    end

    if linked_list_exercise_progress[:earned_for].nil? && simple_linked_list_exercise_progress[:earned_for].present?
      exercises_progress.delete(linked_list_exercise_progress)
    else
      exercises_progress.delete(simple_linked_list_exercise_progress)
    end

    exercises_progress
  end
end
