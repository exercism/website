require "test_helper"

class User::Challenges::FeaturedExercisesProgress48In24Test < ActiveSupport::TestCase
  test "returns status for all features exercises, regardless whether the user has completed it" do
    user = create :user

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user)

    assert_equal 48, progress.size
    progress.each do |exercise_progress|
      assert_equal :in_progress, exercise_progress.status
    end
  end

  test "returns progress order by week" do
    user = create :user

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user)

    assert_equal (1..48).to_a, progress.map(&:week)
  end

  test "returns completed tracks" do
    user = create :user

    create_completed_solution(user, 2022, 'reverse-string', 'cpp')
    create_completed_solution(user, 2023, 'reverse-string', 'nim')
    create_completed_solution(user, 2024, 'leap', 'elixir')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal ({ "cpp" => 2022, "nim" => 2023 }), exercise_progress["reverse-string"].completed_tracks
    assert_equal ({ "elixir" => 2024 }), exercise_progress["leap"].completed_tracks
  end

  test "gold status when user has completed all three featured tracks in 2024" do
    user = create :user

    create_completed_solution(user, 2024, 'reverse-string', 'cpp')
    create_completed_solution(user, 2024, 'reverse-string', 'nim')
    create_completed_solution(user, 2024, 'reverse-string', 'javascript')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal :gold, exercise_progress["reverse-string"].status
  end

  test "gold status when completed all featured tracks and at least three iterations in 2024" do
    user = create :user

    create_completed_solution(user, 2021, 'reverse-string', 'cpp')
    create_completed_solution(user, 2022, 'reverse-string', 'csharp')
    create_completed_solution(user, 2023, 'reverse-string', 'javascript')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal :in_progress, exercise_progress["reverse-string"].status

    # Create two iterations in 2024
    create_completed_solution(user, 2024, 'reverse-string', 'zig')
    create_completed_solution(user, 2024, 'reverse-string', 'nim')

    exercise_progress = progress_by_exercise(progress)
    assert_equal :in_progress, exercise_progress["reverse-string"].status

    # Ensure that there are now three iterations in 2024
    create_completed_solution(user, 2024, 'reverse-string', 'racket')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)
    exercise_progress = progress_by_exercise(progress)
    assert_equal :gold, exercise_progress["reverse-string"].status
  end

  test "silver status when user has completed at least three tracks in 2024 (but not the three featured ones)" do
    user = create :user

    create_completed_solution(user, 2024, 'reverse-string', 'zig')
    create_completed_solution(user, 2024, 'reverse-string', 'csharp')
    create_completed_solution(user, 2024, 'reverse-string', 'nim')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal :silver, exercise_progress["reverse-string"].status

    # Even if the user has started all three featured tracks, they don't count if they're not completed
    create_non_completed_solution(user, 2024, 'reverse-string', 'python')
    create_non_completed_solution(user, 2024, 'reverse-string', 'javascript')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal :silver, exercise_progress["reverse-string"].status
  end

  test "bronze status when user has completed at least one track in 2024" do
    user = create :user
    create_completed_solution(user, 2024, 'reverse-string', 'kotlin')

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    exercise_progress = progress_by_exercise(progress)
    assert_equal :bronze, exercise_progress["reverse-string"].status
  end

  private
  def progress_by_exercise(progress) = progress.index_by(&:slug)

  def create_completed_solution(user, year, exercise_slug, track_slug)
    travel_to Time.utc(year, SecureRandom.random_number(1..12), SecureRandom.random_number(1..28)) do
      track = create(:track, slug: track_slug)
      exercise = create(:practice_exercise, slug: exercise_slug, track:)
      create(:practice_solution, :completed, user:, exercise:)
    end
  end

  def create_non_completed_solution(user, year, exercise_slug, track_slug)
    travel_to Time.utc(year, SecureRandom.random_number(1..12), SecureRandom.random_number(1..28)) do
      track = create(:track, slug: track_slug)
      exercise = create(:practice_exercise, slug: exercise_slug, track:)
      create(:practice_solution, user:, exercise:)
    end
  end
end
