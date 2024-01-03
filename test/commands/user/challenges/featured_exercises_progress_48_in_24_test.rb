require "test_helper"

class User::Challenges::FeaturedExercisesProgress48In24Test < ActiveSupport::TestCase
  test "returns status for all features exercises, regardless whether the user has iterated it" do
    user = create :user

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user)

    assert_equal 2, progress.size # TODO: change to 48 once we've selected them all
    progress.each do |exercise_progress|
      assert_equal :in_progress, exercise_progress[:status]
    end
  end

  test "returns iterated tracks" do
    user = create :user

    create(:iteration,
      solution: create(:practice_solution, user:,
        created_at: Time.utc(2022, 1, 1),
        exercise: create(:practice_exercise, slug: 'hello-world', track: create(:track, slug: 'python'))))
    create(:iteration,
      solution: create(:practice_solution, user:, created_at: Time.utc(2023, 6, 3),
        exercise: create(:practice_exercise, slug: 'hello-world', track: create(:track, slug: 'prolog'))))
    create(:iteration,
      solution: create(:practice_solution, user:, created_at: Time.utc(2024, 10, 23),
        exercise: create(:practice_exercise, slug: 'leap', track: create(:track, slug: 'elixir'))))

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    assert_equal 2, progress.size # TODO: change to 48 once we've selected them all
    exercise_progress = progress_by_exercise(progress)
    assert_equal %w[python prolog], exercise_progress["hello-world"][:iterated_tracks]
    assert_equal %w[elixir], exercise_progress["leap"][:iterated_tracks]
  end

  test "gold status when user has iterated in all three featured tracks" do
    user = create :user

    create(:iteration,
      solution: create(:practice_solution, user:, created_at: Time.utc(2022, 1, 1),
        exercise: create(:practice_exercise, slug: 'hello-world', track: create(:track, slug: 'python'))))
    create(:iteration,
      solution: create(:practice_solution, user:, created_at: Time.utc(2023, 6, 3),
        exercise: create(:practice_exercise, slug: 'hello-world', track: create(:track, slug: 'csharp'))))
    create(:iteration,
      solution: create(:practice_solution, user:, created_at: Time.utc(2024, 10, 23),
        exercise: create(:practice_exercise, slug: 'hello-world', track: create(:track, slug: 'javascript'))))

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    assert_equal 2, progress.size # TODO: change to 48 once we've selected them all
    exercise_progress = progress_by_exercise(progress)
    assert_equal :gold, exercise_progress["hello-world"][:status]
    assert_equal :in_progress, exercise_progress["leap"][:status]
  end

  test "silver status when user has iterated in at least three tracks in 2024 (but not in three features ones)" do
    user = create :user

    create(:iteration,
      solution: create(:practice_solution, user:, created_at: Time.utc(2024, 1, 1),
        exercise: create(:practice_exercise, slug: 'hello-world', track: create(:track, slug: 'csharp'))))
    create(:iteration,
      solution: create(:practice_solution, user:, created_at: Time.utc(2024, 6, 3),
        exercise: create(:practice_exercise, slug: 'hello-world', track: create(:track, slug: 'zig'))))
    create(:iteration,
      solution: create(:practice_solution, user:, created_at: Time.utc(2024, 10, 23),
        exercise: create(:practice_exercise, slug: 'hello-world', track: create(:track, slug: 'nim'))))

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    assert_equal 2, progress.size # TODO: change to 48 once we've selected them all
    exercise_progress = progress_by_exercise(progress)
    assert_equal :silver, exercise_progress["hello-world"][:status]
    assert_equal :in_progress, exercise_progress["leap"][:status]
  end

  test "bronze status when user has iterated in at least one track in 2024" do
    user = create :user

    create(:iteration,
      solution: create(:practice_solution, user:, created_at: Time.utc(2024, 1, 1),
        exercise: create(:practice_exercise, slug: 'hello-world', track: create(:track, slug: 'csharp'))))

    progress = User::Challenges::FeaturedExercisesProgress48In24.(user.reload)

    assert_equal 2, progress.size # TODO: change to 48 once we've selected them all
    exercise_progress = progress_by_exercise(progress)
    assert_equal :bronze, exercise_progress["hello-world"][:status]
    assert_equal :in_progress, exercise_progress["leap"][:status]
  end

  def progress_by_exercise(progress) = progress.index_by { |exercise_progress| exercise_progress[:slug] }
end
