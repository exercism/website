require "test_helper"

class User::Challenges::FeaturedExercisesProgress12In23Test < ActiveSupport::TestCase
  test "returns track/exercise slugs of solutions published in 2023" do
    user = create :user
    nim = create :track, slug: 'nim'
    prolog = create :track, slug: 'prolog'

    nim_exercise = create :practice_exercise, slug: 'sieve', track: nim
    prolog_exercise = create :practice_exercise, slug: 'raindrops', track: prolog

    create :practice_solution, :published, user:, exercise: nim_exercise, published_at: Time.utc(2023, 3, 17)
    create :practice_solution, :published, user:, exercise: prolog_exercise, published_at: Time.utc(2023, 5, 23)

    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)

    expected_sieve = { slug: 'sieve', earned_for: 'nim', track_slugs: %w[c cpp d nim go rust vlang zig] }
    assert_equal expected_sieve, (progress.find { |exercise_progress| exercise_progress[:slug] == 'sieve' })

    expected_raindrops = { slug: 'raindrops', earned_for: 'prolog',
                           track_slugs: %w[ballerina pharo-smalltalk prolog red rust tcl unison] }
    assert_equal expected_raindrops, (progress.find { |exercise_progress| exercise_progress[:slug] == 'raindrops' })
  end

  test "returns single result per exercise" do
    user = create :user
    nim = create :track, slug: 'nim'
    rust = create :track, slug: 'rust'

    nim_exercise = create :practice_exercise, slug: 'sieve', track: nim
    rust_exercise = create :practice_exercise, slug: 'sieve', track: rust

    create :practice_solution, :published, user:, exercise: nim_exercise, published_at: Time.utc(2023, 3, 17)
    create :practice_solution, :published, user:, exercise: rust_exercise, published_at: Time.utc(2023, 5, 23)

    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)

    expected = { slug: 'sieve', earned_for: 'nim', track_slugs: %w[c cpp d nim go rust vlang zig] }
    assert_equal expected, (progress.find { |exercise_progress| exercise_progress[:slug] == 'sieve' })
  end

  test "ignore invalid track/exercise combination" do
    user = create :user
    fsharp = create :track, slug: 'fsharp'
    fsharp_exercise = create :practice_exercise, slug: 'sieve', track: fsharp
    create :practice_solution, :published, user:, exercise: fsharp_exercise, published_at: Time.utc(2023, 5, 23)

    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)

    expected = { slug: 'sieve', earned_for: nil, track_slugs: %w[c cpp d nim go rust vlang zig] }
    assert_equal expected, (progress.find { |exercise_progress| exercise_progress[:slug] == 'sieve' })
  end

  test "include exercise if not published in 2023 and published for all featured tracks before 2023 " do
    user = create :user
    julia = create :track, slug: 'julia'
    python = create :track, slug: 'python'
    r = create :track, slug: 'r'
    julia_exercise_etl = create :practice_exercise, slug: 'etl', track: julia
    python_exercise_etl = create :practice_exercise, slug: 'etl', track: python
    r_exercise_etl = create :practice_exercise, slug: 'etl', track: r

    # Sanity check
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected = { slug: 'etl', earned_for: nil, track_slugs: %w[julia python r] }
    assert_equal expected, (progress.find { |exercise_progress| exercise_progress[:slug] == 'etl' })

    # Sanity check
    create :practice_solution, :published, user:, exercise: julia_exercise_etl, published_at: Time.utc(2021, 2, 7)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected = { slug: 'etl', earned_for: nil, track_slugs: %w[julia python r] }
    assert_equal expected, (progress.find { |exercise_progress| exercise_progress[:slug] == 'etl' })

    # Sanity check
    create :practice_solution, :published, user:, exercise: python_exercise_etl, published_at: Time.utc(2021, 12, 30)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected = { slug: 'etl', earned_for: nil, track_slugs: %w[julia python r] }
    assert_equal expected, (progress.find { |exercise_progress| exercise_progress[:slug] == 'etl' })

    create :practice_solution, :published, user:, exercise: r_exercise_etl, published_at: Time.utc(2018, 8, 8)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected = { slug: 'etl', earned_for: 'julia', track_slugs: %w[julia python r] }
    assert_equal expected, (progress.find { |exercise_progress| exercise_progress[:slug] == 'etl' })
  end

  test "don't double count linked-list and simple-linked-list exercises" do
    user = create :user
    nim = create :track, slug: 'nim'
    kotlin = create :track, slug: 'kotlin'
    go = create :track, slug: 'go'

    linked_list_exercise = create :practice_exercise, slug: 'linked-list', track: nim
    linked_list_exercise_kotlin = create :practice_exercise, slug: 'linked-list', track: kotlin
    linked_list_exercise_go = create :practice_exercise, slug: 'linked-list', track: go
    simple_linked_list_exercise = create :practice_exercise, slug: 'simple-linked-list', track: nim

    linked_list_solution = create :practice_solution, :published, user:, exercise: linked_list_exercise,
      published_at: Time.utc(2023, 3, 17)

    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected_linked_list = { slug: 'linked-list', earned_for: 'nim', track_slugs: %w[c cpp d nim go rust vlang zig] }
    assert_equal expected_linked_list, (progress.find { |exercise_progress| exercise_progress[:slug] == 'linked-list' })
    assert_nil(progress.find { |exercise_progress| exercise_progress[:slug] == 'simple-linked-list' })

    simple_linked_list_solution = create :practice_solution, :published, user:, exercise: simple_linked_list_exercise,
      published_at: Time.utc(2023, 3, 24)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected_linked_list = { slug: 'linked-list', earned_for: 'nim', track_slugs: %w[c cpp d nim go rust vlang zig] }
    assert_equal expected_linked_list, (progress.find { |exercise_progress| exercise_progress[:slug] == 'linked-list' })
    assert_nil(progress.find { |exercise_progress| exercise_progress[:slug] == 'simple-linked-list' })

    linked_list_solution.update(published_at: nil)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected_simple_linked_list = { slug: 'simple-linked-list', earned_for: 'nim', track_slugs: %w[c cpp d nim go rust vlang zig] }
    assert_nil(progress.find { |exercise_progress| exercise_progress[:slug] == 'linked-list' })
    assert_equal expected_simple_linked_list, (progress.find { |exercise_progress| exercise_progress[:slug] == 'simple-linked-list' })

    simple_linked_list_solution.update(published_at: nil)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected_linked_list = { slug: 'linked-list', earned_for: nil, track_slugs: %w[c cpp d nim go rust vlang zig] }
    assert_equal expected_linked_list, (progress.find { |exercise_progress| exercise_progress[:slug] == 'linked-list' })
    assert_nil(progress.find { |exercise_progress| exercise_progress[:slug] == 'simple-linked-list' })

    Solution.destroy_all

    # Ignore non Mechanical March linked-list solution
    create :practice_solution, :published, user:, exercise: simple_linked_list_exercise,
      published_at: Time.utc(2023, 3, 24)
    create :practice_solution, :published, user:, exercise: linked_list_exercise_kotlin,
      published_at: Time.utc(2023, 3, 24)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected_simple_linked_list = { slug: 'simple-linked-list', earned_for: 'nim', track_slugs: %w[c cpp d nim go rust vlang zig] }
    assert_nil(progress.find { |exercise_progress| exercise_progress[:slug] == 'linked-list' })
    assert_equal expected_simple_linked_list, (progress.find { |exercise_progress| exercise_progress[:slug] == 'simple-linked-list' })

    Solution.destroy_all

    # Ignore Mechanical March linked-list solution not published in 2023
    create :practice_solution, :published, user:, exercise: simple_linked_list_exercise,
      published_at: Time.utc(2023, 3, 24)
    create :practice_solution, :published, user:, exercise: linked_list_exercise_go,
      published_at: Time.utc(2022, 3, 24)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    expected_simple_linked_list = { slug: 'simple-linked-list', earned_for: 'nim', track_slugs: %w[c cpp d nim go rust vlang zig] }
    assert_nil(progress.find { |exercise_progress| exercise_progress[:slug] == 'linked-list' })
    assert_equal expected_simple_linked_list, (progress.find { |exercise_progress| exercise_progress[:slug] == 'simple-linked-list' })
  end

  test "lists exercises by order of appearance" do
    user = create :user
    expected = User::Challenges::FeaturedExercisesProgress12In23.featured_exercises.keys.flatten - ["simple-linked-list"]
    actual = User::Challenges::FeaturedExercisesProgress12In23.(user)
    assert_equal expected, actual.pluck(:slug)
  end
end
