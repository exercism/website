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

    expected = [
      [nim.slug, nim_exercise.slug],
      [prolog.slug, prolog_exercise.slug]
    ]
    assert_equal expected, progress
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

    expected = [[nim.slug, nim_exercise.slug]]
    assert_equal expected, progress
  end

  test "ignore invalid track/exercise combination" do
    user = create :user
    fsharp = create :track, slug: 'fsharp'
    fsharp_exercise = create :practice_exercise, slug: 'sieve', track: fsharp
    create :practice_solution, :published, user:, exercise: fsharp_exercise, published_at: Time.utc(2023, 5, 23)

    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)

    assert_empty progress
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
    assert_empty User::Challenges::FeaturedExercisesProgress12In23.(user.reload)

    # Sanity check
    create :practice_solution, :published, user:, exercise: julia_exercise_etl, published_at: Time.utc(2021, 2, 7)
    assert_empty User::Challenges::FeaturedExercisesProgress12In23.(user.reload)

    # Sanity check
    create :practice_solution, :published, user:, exercise: python_exercise_etl, published_at: Time.utc(2021, 12, 30)
    assert_empty User::Challenges::FeaturedExercisesProgress12In23.(user.reload)

    create :practice_solution, :published, user:, exercise: r_exercise_etl, published_at: Time.utc(2018, 8, 8)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)

    expected = [[julia.slug, julia_exercise_etl.slug]]
    assert_equal expected, progress
  end

  test "don't double count linked-list and simple-linked-list exercises" do
    user = create :user
    nim = create :track, slug: 'nim'
    kotlin = create :track, slug: 'kotlin'
    go = create :track, slug: 'go'

    linked_list_exercise = create :practice_exercise, slug: 'linked-list', track: nim
    linked_list_exercise_kotlin = create :practice_exercise, slug: 'linked-list', track: kotlin
    linked_list_exercise_nim = create :practice_exercise, slug: 'linked-list', track: nim
    linked_list_exercise_go = create :practice_exercise, slug: 'linked-list', track: go
    simple_linked_list_exercise = create :practice_exercise, slug: 'simple-linked-list', track: nim

    linked_list_solution = create :practice_solution, :published, user:, exercise: linked_list_exercise,
      published_at: Time.utc(2023, 3, 17)

    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    assert_equal [[nim.slug, linked_list_exercise.slug]], progress

    simple_linked_list_solution = create :practice_solution, :published, user:, exercise: simple_linked_list_exercise,
      published_at: Time.utc(2023, 3, 24)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    assert_equal [[nim.slug, linked_list_exercise.slug]], progress

    linked_list_solution.update(published_at: nil)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    assert_equal [[nim.slug, simple_linked_list_exercise.slug]], progress

    simple_linked_list_solution.update(published_at: nil)
    assert_empty User::Challenges::FeaturedExercisesProgress12In23.(user.reload)

    Solution.destroy_all

    # Ignore non Mechanical March linked-list solution
    create :practice_solution, :published, user:, exercise: simple_linked_list_exercise,
      published_at: Time.utc(2023, 3, 24)
    create :practice_solution, :published, user:, exercise: linked_list_exercise_kotlin,
      published_at: Time.utc(2023, 3, 24)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    assert_equal [[nim.slug, simple_linked_list_exercise.slug]], progress

    Solution.destroy_all

    # Ignore Mechanical March linked-list solution not published in 2023
    create :practice_solution, :published, user:, exercise: simple_linked_list_exercise,
      published_at: Time.utc(2023, 3, 24)
    create :practice_solution, :published, user:, exercise: linked_list_exercise_go,
      published_at: Time.utc(2022, 3, 24)
    progress = User::Challenges::FeaturedExercisesProgress12In23.(user.reload)
    assert_equal [[nim.slug, simple_linked_list_exercise.slug]], progress
  end
end
