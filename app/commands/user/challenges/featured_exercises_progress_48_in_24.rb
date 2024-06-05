class User::Challenges::FeaturedExercisesProgress48In24
  include Mandate

  initialize_with :user

  # rubocop:disable Layout/LineLength
  EXERCISES = [
    { week: 1, slug: 'leap', title: 'Leap', featured_tracks: %w[python clojure mips], learning_opportunity: "This is a relatively simple exercise, but can teach you a lot about how to write idiomatic code in a language. Should you use boolean logic, early returns, pattern matching, or something more language specific? Whatever you do, just don't use the built-in leap-year method!" },
    { week: 2, slug: 'reverse-string', title: 'Reverse String', featured_tracks: %w[javascript nim cpp], learning_opportunity: "This is a classic job interview question and at first feels a bit simple, but as you dig into Unicode, Graphemes, stack-vs-heap allocation and pointers, you'll find there's tons more to explore!" },
    { week: 3, slug: 'raindrops', title: 'Raindrops', featured_tracks: %w[ruby r common-lisp], learning_opportunity: "Another exercise with a simple naive approach, but tons of depth when you dig in to it. Explore magical Lisp strings, matrix multiplication, table-based lookup via macros, and much more." },
    { week: 4, slug: 'roman-numerals', title: 'Roman Numerals', featured_tracks: %w[elixir pharo-smalltalk julia], learning_opportunity: "This is a tricky little exercise and one that can be solved in multiple ways. Explore recursion, pattern matching, table-based lookups and maybe see if you can come up with a solution based on the relationship between the numbers 2 and 5..." },
    { week: 5, slug: 'protein-translation', title: 'Protein Translation', featured_tracks: %w[fsharp crystal csharp], learning_opportunity: "This is a fun little exercise that lets you delve into recursion, pattern matching, higher order functions, and other functional concepts. Our featured solutions also use bitshifting, regexp and more!" },
    { week: 6, slug: 'list-ops', title: 'List Ops', featured_tracks: %w[gleam swift sml], learning_opportunity: "This exercise is the perfect space to explore the imperative and functional approaches to common functions. Compare both types of coding, and try to optimise your solution to use tail-call recursion!" },
    { week: 7, slug: 'acronym', title: 'Acronym', featured_tracks: %w[haskell tcl powershell], learning_opportunity: "This exercise is the perfect space to explore regular expressions. You can solve the exercise using basic techniques or more complex ones, but can you solve it using just one regular single expression?" },
    { week: 8, slug: 'circular-buffer', title: 'Circular Buffer', featured_tracks: %w[c groovy scala], learning_opportunity: "Circular Buffers are First In, First Out (FIFO) queues that are a fixed size. They're usually backed by an array, which gives it great spatial/data locality (good for performance!). Explore different ways to create them yourself!" },
    { week: 9, slug: 'parallel-letter-frequency', title: 'Parallel Letter Frequency', featured_tracks: %w[go java elixir], learning_opportunity: "Learn about the difference between concurrency and parallellism and how they affect performance. Explore different ways to run code in parallel and how to avoid concurrency issues through mutexes or concurrent collections." },
    { week: 10, slug: 'allergies', title: 'Allergies', featured_tracks: %w[nim elm rust], learning_opportunity: "Learn about bitwise operations, bitshifting, bitwise comparison and other binary number concepts, or try solving the exercise functionally with pattern matching and recursion." },
    { week: 11, slug: 'sieve', title: 'Sieve', featured_tracks: %w[zig bash fortran], learning_opportunity: "Though usually implemented using a fixed-size buffer and nested loops, this exercise is the perfect place to explore bitwise representations and clever loop limits to improve memory and performance." },
    { week: 12, slug: 'luhn', title: 'Luhn', featured_tracks: %w[typescript perl5 awk], learning_opportunity: "Explore different ways to validate input and to double every other digit, which can be done in some surprising ways, with imperative, OOP and functional ways all possible!" },
    { week: 13, slug: 'scrabble-score', title: 'Scrabble Score', featured_tracks: %w[python scheme c], learning_opportunity: "Learn to use loops, dictionaries, pattern matching and lookup tables to sum a word's letter scores! Or try and get creative to solve it with regular expressions." },
    { week: 14, slug: 'difference-of-squares', title: 'Difference Of Squares', featured_tracks: %w[r wasm swift], learning_opportunity: "" },
    { week: 15, slug: 'pangram', title: 'Pangram', featured_tracks: %w[julia elixir go], learning_opportunity: "Learn how to use higher-order functions to filter and count unique letters, or try using set operations or even bitwise operations to efficiently keep track of seen letters." },
    { week: 16, slug: 'all-your-base', title: 'All Your Base', featured_tracks: %w[cpp erlang groovy], learning_opportunity: "Learn to use modulo arithmetic or built-in functions to convert between bases. Or try a long multiplication approach that doesn't require converting to a base 10 intermediate value!" },
    { week: 17, slug: 'zebra-puzzle', title: 'Zebra Puzzle', featured_tracks: %w[prolog scala javascript], learning_opportunity: "Learn to efficiently find the solution in billions of possible solutions. Use lazy evaluation and some early filtering to exclude invalid permutations. Or use depth-first searching, the AC-3 algorithm or even a genetic algorithm to find the solution!" },
    { week: 18, slug: 'minesweeper', title: 'Minesweeper', featured_tracks: %w[pharo-smalltalk ocaml crystal], learning_opportunity: "Learn to annotate a collection of strings using loops, a functional pipeline or even two-dimensional matrices!" },
    { week: 19, slug: 'dnd-character', title: 'D&D Character', featured_tracks: %w[unison nim tcl], learning_opportunity: "Learn how to generate random values and use them to build a D&D character." },
    { week: 20, slug: 'pig-latin', title: 'Pig Latin', featured_tracks: %w[bash lua csharp], learning_opportunity: "Learn to transform text via loops, pattern matching or regular expressions." },
    { week: 21, slug: 'space-age', title: 'Space Age', featured_tracks: %w[clojure ruby python], learning_opportunity: "Learn how to use dictionaries and pattern matching to calculate someone's age on another planet. Or get fancy with some meta-programming or using reciprocals to turn division into multiplication." },
    { week: 22, slug: 'yacht', title: 'Yacht', featured_tracks: %w[common-lisp rust fsharp], learning_opportunity: "Learn how to score dice by tallying them in a dictionary, using higher-order functions and/or (custom) pattern matching." },
    { week: 23, slug: 'matching-brackets', title: 'Matching Brackets', featured_tracks: %w[racket zig vbnet], learning_opportunity: "Learn how to check for balanced brackets via repeated string replacement, regular expressions or by using a stack. Or get fancy and use a grammar based approach." },
    { week: 24, slug: 'rna-transcription', title: 'RNA Transcription', featured_tracks: %w[scheme elm abap], learning_opportunity: "" },
    { week: 25, slug: 'binary-search', title: 'Binary Search', featured_tracks: %w[fortran ballerina ocaml], learning_opportunity: "" },
    { week: 26, slug: 'spiral-matrix', title: 'Spiral Matrix', featured_tracks: %w[vbnet purescript go], learning_opportunity: "" },
    { week: 27, slug: 'secret-handshake', title: 'Secret Handshake', featured_tracks: %w[cpp raku haskell], learning_opportunity: "" },
    { week: 28, slug: 'anagram', title: 'Anagram', featured_tracks: %w[cobol lfe reasonml], learning_opportunity: "" },
    { week: 29, slug: 'kindergarten-garden', title: 'Kindergarten Garden', featured_tracks: %w[c awk perl5], learning_opportunity: "" },
    { week: 30, slug: 'robot-simulator', title: 'Robot Simulator', featured_tracks: %w[typescript gleam python], learning_opportunity: "" },
    { week: 31, slug: 'knapsack', title: 'Knapsack', featured_tracks: %w[java jq prolog], learning_opportunity: "" },
    { week: 32, slug: 'meetup', title: 'Meetup', featured_tracks: %w[purescript erlang php], learning_opportunity: "" },
    { week: 33, slug: 'pascals-triangle', title: 'Pascals Triangle', featured_tracks: %w[dart coffeescript julia], learning_opportunity: "" },
    { week: 34, slug: 'hamming', title: 'Hamming', featured_tracks: %w[csharp 8th wren], learning_opportunity: "" },
    { week: 35, slug: 'rotational-cipher', title: 'Rotational Cipher', featured_tracks: %w[bash unison kotlin], learning_opportunity: "" },
    { week: 36, slug: 'phone-number', title: 'Phone Number', featured_tracks: %w[raku elixir swift], learning_opportunity: "" },
    { week: 37, slug: 'isogram', title: 'Isogram', featured_tracks: %w[awk rust prolog], learning_opportunity: "" },
    { week: 38, slug: 'bob', title: 'Bob', featured_tracks: %w[ruby fsharp d], learning_opportunity: "" },
    { week: 39, slug: 'two-bucket', title: 'Two Bucket', featured_tracks: %w[crystal vlang elm], learning_opportunity: "" },
    { week: 40, slug: 'grade-school', title: 'Grade School', featured_tracks: %w[powershell gleam lua], learning_opportunity: "" },
    { week: 41, slug: 'bank-account', title: 'Bank Account', featured_tracks: %w[java erlang clojure], learning_opportunity: "" },
    { week: 42, slug: 'food-chain', title: 'Food Chain', featured_tracks: %w[ruby go haskell], learning_opportunity: "" },
    { week: 43, slug: 'eliuds-eggs', title: 'Eliud\'s Eggs', featured_tracks: %w[x86-64-assembly racket 8th], learning_opportunity: "" },
    { week: 44, slug: 'collatz-conjecture', title: 'Collatz Conjecture', featured_tracks: %w[rust csharp jq], learning_opportunity: "" },
    { week: 45, slug: 'run-length-encoding', title: 'Run-Length Encoding', featured_tracks: %w[wasm elm kotlin], learning_opportunity: "" },
    { week: 46, slug: 'armstrong-numbers', title: 'Armstrong Numbers', featured_tracks: %w[mips d javascript], learning_opportunity: "" },
    { week: 47, slug: 'diamond', title: 'Diamond', featured_tracks: %w[wren tcl cfml], learning_opportunity: "" },
    { week: 48, slug: 'largest-series-product', title: 'Largest Series Product', featured_tracks: %w[lua groovy scala], learning_opportunity: "" }
  ].freeze
  # rubocop:enable Layout/LineLength

  def call = EXERCISES.map { |exercise| exercise_progress(exercise) }

  private
  def exercise_progress(exercise)
    FeaturedExercise.new(
      **exercise.merge({
        exercise: csharp_exercises[exercise[:slug]],
        completed_tracks: completions[exercise[:slug]].to_h,
        status: status(exercise)
      })
    )
  end

  def status(exercise)
    completed_exercises = completions[exercise[:slug]].to_a
    return :in_progress if completed_exercises.blank?

    num_completions_in_2024 = completed_exercises.count { |(_, year)| year == 2024 }
    return :in_progress if num_completions_in_2024.zero?
    return :bronze if num_completions_in_2024 < 3

    completed_featured_tracks = (exercise[:featured_tracks] - completed_exercises.map(&:first)).empty?
    completed_featured_tracks ? :gold : :silver
  end

  memoize
  def completions
    user.solutions.completed.
      joins(exercise: :track).
      where(exercise: { slug: EXERCISES.pluck(:slug) }).
      pluck('exercise.slug', 'tracks.slug', 'YEAR(completed_at)').
      group_by(&:first).
      transform_values { |entries| entries.map { |entry| entry[1..] } }
  end

  def csharp_exercises
    Track.find('csharp').practice_exercises.index_by(&:slug)
  rescue ActiveRecord::RecordNotFound
    {}
  end

  FeaturedExercise = Struct.new(
    :week, :slug, :title, :featured_tracks, :completed_tracks, :status, :learning_opportunity, :exercise,
    keyword_init: true
  ) do
    delegate :title, :icon_url, :blurb, to: :exercise
  end
end
