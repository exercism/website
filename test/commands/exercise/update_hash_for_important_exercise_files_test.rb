require "test_helper"

class Exercise::UpdateHashForImportantExerciseFilesTest < ActiveSupport::TestCase
  test "updates exercise git_important_files_hash if recalculated hash is different" do
    exercise = create :practice_exercise
    Git::GenerateHashForImportantExerciseFiles.stubs(:call).returns("new-hash")

    Exercise::UpdateHashForImportantExerciseFiles.(exercise)

    assert_equal "new-hash", exercise.git_important_files_hash
  end

  test "updates exercise solutions with same git_important_files_hash if recalculated hash is different" do
    track = create :track
    other_track = create :track, slug: 'fsharp'

    exercise = create :practice_exercise, track: track
    solution_same_hash_1 = create :practice_solution, exercise: exercise, git_important_files_hash: exercise.git_important_files_hash
    solution_same_hash_2 = create :practice_solution, exercise: exercise, git_important_files_hash: exercise.git_important_files_hash
    solution_different_hash = create :practice_solution, git_important_files_hash: "different hash"

    # Sanity check for different exercise, same track, same SHA
    different_exercise_same_track_same_sha = create :practice_exercise, slug: exercise.slug, track: exercise.track,
git_important_files_hash: exercise.git_important_files_hash

    # Sanity check for same exercise, different track, same SHA
    same_exercise_different_track_same_sha = create :practice_exercise, slug: exercise.slug, track: other_track,
git_important_files_hash: exercise.git_important_files_hash

    Git::GenerateHashForImportantExerciseFiles.stubs(:call).returns("new-hash")

    Exercise::UpdateHashForImportantExerciseFiles.(exercise)

    assert_equal "new-hash", solution_same_hash_1.reload.git_important_files_hash
    assert_equal "new-hash", solution_same_hash_2.reload.git_important_files_hash
    refute_equal "new-hash", solution_different_hash.reload.git_important_files_hash
    refute_equal "new-hash", different_exercise_same_track_same_sha.reload.git_important_files_hash
    refute_equal "new-hash", same_exercise_different_track_same_sha.reload.git_important_files_hash
  end

  test "does not update exercise git_important_files_hash if recalculated hash is the same" do
    exercise = create :practice_exercise
    before_updated_at = exercise.updated_at
    Git::GenerateHashForImportantExerciseFiles.stubs(:call).returns(exercise.git_important_files_hash)

    Exercise::UpdateHashForImportantExerciseFiles.(exercise)

    assert_equal before_updated_at, exercise.updated_at
  end
end
