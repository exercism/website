require 'test_helper'

class Git::ProblemSpecificationsCopyTest < ActiveSupport::TestCase
  setup do
    TestHelpers.use_problem_specifications_test_repo!
  end

  test "exercises" do
    git = Git::ProblemSpecifications.new

    expected = %w[
      accumulate
      acronym
      affine-cipher
      all-your-base
      allergies
      alphametics
      anagram
      armstrong-numbers
      atbash-cipher
      bank-account
      beer-song
      binary
      binary-search
      binary-search-tree
      bob
      book-store
      bottle-song
      bowling
      change
      circular-buffer
      clock
      collatz-conjecture
      complex-numbers
      connect
      counter
      crypto-square
      custom-set
      darts
      diamond
      difference-of-squares
      diffie-hellman
      dnd-character
      dominoes
      dot-dsl
      error-handling
      etl
      flatten-array
      food-chain
      forth
      gigasecond
      go-counting
      grade-school
      grains
      grep
      hamming
      hangman
      hello-world
      hexadecimal
      high-scores
      house
      isbn-verifier
      isogram
      killer-sudoku-helper
      kindergarten-garden
      knapsack
      largest-series-product
      leap
      ledger
      lens-person
      linked-list
      list-ops
      luhn
      markdown
      matching-brackets
      matrix
      meetup
      micro-blog
      minesweeper
      nth-prime
      nucleotide-codons
      nucleotide-count
      ocr-numbers
      octal
      paasio
      palindrome-products
      pangram
      parallel-letter-frequency
      pascals-triangle
      perfect-numbers
      phone-number
      pig-latin
      point-mutations
      poker
      pov
      prime-factors
      protein-translation
      proverb
      pythagorean-triplet
      queen-attack
      rail-fence-cipher
      raindrops
      rational-numbers
      react
      rectangles
      resistor-color
      resistor-color-duo
      resistor-color-trio
      rest-api
      reverse-string
      rna-transcription
      robot-name
      robot-simulator
      roman-numerals
      rotational-cipher
      run-length-encoding
      saddle-points
      satellite
      say
      scale-generator
      scrabble-score
      secret-handshake
      series
      sgf-parsing
      sieve
      simple-cipher
      simple-linked-list
      space-age
      spiral-matrix
      square-root
      state-of-tic-tac-toe
      strain
      sublist
      sum-of-multiples
      tournament
      transpose
      tree-building
      triangle
      trinary
      twelve-days
      two-bucket
      two-fer
      variable-length-quantity
      word-count
      word-search
      wordy
      yacht
      zebra-puzzle
      zipper
    ]
    assert_equal expected, git.exercises.map(&:slug).sort
  end

  test "active_exercise_slugs" do
    git = Git::ProblemSpecifications.new

    assert_includes git.active_exercise_slugs, "acronym"
    assert_includes git.active_exercise_slugs, "zipper"
    refute_includes git.active_exercise_slugs, "binary"
    refute_includes git.active_exercise_slugs, "octal"
  end
end
