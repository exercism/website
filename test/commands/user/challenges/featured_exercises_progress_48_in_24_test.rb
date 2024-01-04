require "test_helper"

class User::Challenges::FeaturedExercisesProgress48In24Test < ActiveSupport::TestCase
  test "returns status for all features exercises, regardless whether the user has iterated it" do
    user = create :user

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user)

    assert_equal 2, progress.size # TODO: change to 48 once we've selected them all
    progress.each do |exercise_progress|
      assert_equal :in_progress, exercise_progress.status
    end
  end

  test "returns progress order by week" do
    user = create :user

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user)

    assert_equal (3..4).to_a, progress.map(&:week)
  end

  test "returns iterated tracks" do
    user = create :user
    create_iteration(user, 2022, 'hello-world', 'python')
    create_iteration(user, 2023, 'hello-world', 'prolog')
    create_iteration(user, 2024, 'leap', 'elixir')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal ({ "python" => 2022, "prolog" => 2023 }), exercise_progress["hello-world"].iterated_tracks
    assert_equal ({ "elixir" => 2024 }), exercise_progress["leap"].iterated_tracks
  end

  test "gold status when user has iterated in all three featured tracks in 2024" do
    user = create :user
    create_iteration(user, 2024, 'hello-world', 'python')
    create_iteration(user, 2024, 'hello-world', 'csharp')
    create_iteration(user, 2024, 'hello-world', 'javascript')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal :gold, exercise_progress["hello-world"].status
  end

  test "gold status when iterated all featured tracks and at least three iterations in 2024" do
    user = create :user
    create_iteration(user, 2021, 'hello-world', 'python')
    create_iteration(user, 2022, 'hello-world', 'csharp')
    create_iteration(user, 2023, 'hello-world', 'javascript')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal :in_progress, exercise_progress["hello-world"].status

    # Create two iterations in 2024
    create_iteration(user, 2024, 'hello-world', 'zig')
    create_iteration(user, 2024, 'hello-world', 'nim')

    exercise_progress = progress_by_exercise(progress)
    assert_equal :in_progress, exercise_progress["hello-world"].status

    # Ensure that there are now three iterations in 2024
    create_iteration(user, 2024, 'hello-world', 'racket')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)
    exercise_progress = progress_by_exercise(progress)
    assert_equal :gold, exercise_progress["hello-world"].status
  end

  test "silver status when user has iterated in at least three tracks in 2024 (but not in three features ones)" do
    user = create :user
    create_iteration(user, 2024, 'hello-world', 'zig')
    create_iteration(user, 2024, 'hello-world', 'csharp')
    create_iteration(user, 2024, 'hello-world', 'nim')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal :silver, exercise_progress["hello-world"].status
  end

  test "bronze status when user has iterated in at least one track in 2024" do
    user = create :user
    create_iteration(user, 2024, 'hello-world', 'kotlin')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal :bronze, exercise_progress["hello-world"].status
  end

  private
  def progress_by_exercise(progress) = progress.index_by(&:slug)

  def create_iteration(user, year, exercise_slug, track_slug)
    travel_to Time.utc(year, SecureRandom.random_number(1..12), SecureRandom.random_number(1..28))

    track = create(:track, slug: track_slug)
    exercise = create(:practice_exercise, slug: exercise_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create(:iteration, solution:)
  end
end
