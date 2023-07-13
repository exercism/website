require "test_helper"

class Exercise::ProcessGitImportantFilesChangedTest < ActiveSupport::TestCase
  test "update solution git data when git important files hash hasn't changed" do
    exercise = create :practice_exercise
    old_git_important_files_hash = exercise.git_important_files_hash

    Exercise::UpdateSolutionGitData.expects(:call).with(exercise, old_git_important_files_hash)

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash)
  end

  test "update solution git data when git important files hash has changed but commit contains magic marker" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: 'cfd8cf31bb9c90fd9160c82db69556a47f7c2a54'
    old_git_important_files_hash = SecureRandom.compact_uuid

    Exercise::UpdateSolutionGitData.expects(:call).with(exercise, old_git_important_files_hash)

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash)
  end

  test "don't update solution git data when git important files hash has changed and commit does not have magic marker" do
    exercise = create :practice_exercise, git_sha: '0b04b8976650d993ecf4603cf7413f3c6b898eff'
    old_git_important_files_hash = SecureRandom.compact_uuid

    Exercise::UpdateSolutionGitData.expects(:call).never

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash)
  end

  test "mark solution as out of date when git important files hash has changed and commit does not have magic marker" do
    exercise = create :practice_exercise, git_sha: '0b04b8976650d993ecf4603cf7413f3c6b898eff'
    old_git_important_files_hash = SecureRandom.compact_uuid

    Exercise::MarkSolutionsAsOutOfDateInIndex.expects(:call).with(exercise)

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash)
  end

  test "queue solution head test runs when git important files hash has changed and commit does not have magic marker" do
    exercise = create :practice_exercise, git_sha: '0b04b8976650d993ecf4603cf7413f3c6b898eff'
    old_git_important_files_hash = SecureRandom.compact_uuid

    Exercise::QueueSolutionHeadTestRuns.expects(:defer).with(exercise)

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash)
  end
end
