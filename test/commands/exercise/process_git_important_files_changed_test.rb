require "test_helper"

class Exercise::ProcessGitImportantFilesChangedTest < ActiveSupport::TestCase
  test "update solution git data when git important files hash hasn't changed" do
    exercise = create :practice_exercise, slug: 'tournament', git_sha: '7a8bd1bbeb0d54a08c39d84d59cc7a8ed54d45aa'
    old_git_important_files_hash = exercise.git_important_files_hash
    old_sha = exercise.git_sha
    old_slug = exercise.slug

    Exercise::UpdateSolutionGitData.expects(:call).with(exercise, old_git_important_files_hash)

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash, old_sha, old_slug)
  end

  test "update solution git data when commit has magic marker" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: 'cfd8cf31bb9c90fd9160c82db69556a47f7c2a54'
    old_git_important_files_hash = SecureRandom.compact_uuid
    old_sha = exercise.git_sha
    old_slug = exercise.slug

    Exercise::UpdateSolutionGitData.expects(:call).with(exercise, old_git_important_files_hash)

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash, old_sha, old_slug)
  end

  test "update solution git data when there are no testable changes" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: '13a73eb2f87254c30e7eea82a0f76f59111486aa'
    old_git_important_files_hash = SecureRandom.compact_uuid
    old_sha = exercise.git_sha
    old_slug = exercise.slug

    Exercise::UpdateSolutionGitData.expects(:call).with(exercise, old_git_important_files_hash)

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash, old_sha, old_slug)
  end

  test "don't update solution git data when git sha has changed, no magic marker present and there are testable changes" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: '13a73eb2f87254c30e7eea82a0f76f59111486aa'
    old_git_important_files_hash = SecureRandom.compact_uuid
    old_sha = 'cfd8cf31bb9c90fd9160c82db69556a47f7c2a54'
    old_slug = exercise.slug

    Exercise::UpdateSolutionGitData.expects(:call).never

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash, old_sha, old_slug)
  end

  test "mark solution as out of date when git sha has changed, no magic marker present and there are testable changes" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: '13a73eb2f87254c30e7eea82a0f76f59111486aa'
    old_git_important_files_hash = SecureRandom.compact_uuid
    old_sha = 'cfd8cf31bb9c90fd9160c82db69556a47f7c2a54'
    old_slug = exercise.slug

    Exercise::MarkSolutionsAsOutOfDateInIndex.expects(:call).with(exercise)

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash, old_sha, old_slug)
  end

  test "queue solution head test runs when git sha hasn't changed, no magic marker present and there are testable changes" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: '13a73eb2f87254c30e7eea82a0f76f59111486aa'
    old_git_important_files_hash = SecureRandom.compact_uuid
    old_sha = 'cfd8cf31bb9c90fd9160c82db69556a47f7c2a54'
    old_slug = exercise.slug

    Exercise::QueueSolutionHeadTestRuns.expects(:defer).with(exercise)

    Exercise::ProcessGitImportantFilesChanged.(exercise, old_git_important_files_hash, old_sha, old_slug)
  end
end
