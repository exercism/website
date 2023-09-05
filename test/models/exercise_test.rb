require 'test_helper'

class ExerciseTest < ActiveSupport::TestCase
  test "to_slug" do
    exercise = create :concept_exercise
    assert_equal exercise.slug, exercise.to_param
  end

  test "prerequisites works correctly" do
    exercise = create :concept_exercise

    concept = create :concept
    create :concept

    exercise.prerequisites << concept

    assert_equal [concept], exercise.reload.prerequisites
  end

  test "scope :without_prerequisites" do
    exercise_1 = create :concept_exercise
    exercise_2 = create :concept_exercise

    assert_equal [exercise_1, exercise_2], Exercise.without_prerequisites

    create :exercise_prerequisite, exercise: exercise_1
    assert_equal [exercise_2], Exercise.without_prerequisites
  end

  test "scope :sorted" do
    exercise_1 = create :practice_exercise, position: 0
    exercise_2 = create :concept_exercise, position: 1
    exercise_3 = create :concept_exercise, position: 2
    exercise_4 = create :practice_exercise, position: 3

    assert_equal [exercise_1, exercise_2, exercise_3, exercise_4], Exercise.sorted
  end

  test "prerequisite_exercises" do
    strings = create :concept
    bools = create :concept
    conditionals = create :concept

    exercise = create :practice_exercise
    exercise.prerequisites << strings
    exercise.prerequisites << bools

    pre_ex_1 = create(:concept_exercise)
    pre_ex_1.taught_concepts << strings

    pre_ex_2 = create(:concept_exercise)
    pre_ex_2.taught_concepts << bools

    pre_ex_3 = create(:concept_exercise)
    pre_ex_3.taught_concepts << conditionals

    assert_equal [pre_ex_1, pre_ex_2], exercise.prerequisite_exercises
  end

  test "difficulty_category" do
    {
      easy: [1, 2, 3],
      medium: [4, 5, 6, 7],
      hard: [8, 9, 10]
    }.each do |category, values|
      values.each do |val|
        assert_equal category, create(:practice_exercise, difficulty: val).difficulty_category
      end
    end
  end

  test "icon_url" do
    exercise = create :practice_exercise, slug: 'bob', icon_name: 'bobby'
    assert_equal "https://assets.exercism.org/exercises/bobby.svg", exercise.icon_url
  end

  test "git_important_files_sha is generated" do
    exercise = create :practice_exercise, slug: 'bob', git_important_files_hash: nil
    assert_equal 'b72b0958a135cddd775bf116c128e6e859bf11e4', exercise.git_important_files_hash
  end

  test "git_important_files_sha is re-generated when git_sha changes" do
    exercise = create :practice_exercise, slug: 'allergies', git_sha: '6f169b92d8500d9ec5f6e69d6927bf732ab5274a',
      git_important_files_hash: nil
    assert_equal 'b428b458004f45ba78c4b9f0c386f9987a17452e', exercise.git_important_files_hash

    exercise.update!(git_sha: '9aba0406b02303efe9542e48ab6f4eee0b00e6f1')
    assert_equal '8fadc126ecd6ef6b7075a36517292beec521e39a', exercise.git_important_files_hash
  end

  test "has_test_runner?" do
    track = create :track, has_test_runner: true
    exercise = create :practice_exercise, track:, has_test_runner: true

    assert exercise.has_test_runner?

    exercise.update(has_test_runner: false)
    refute exercise.has_test_runner?

    exercise.update(has_test_runner: true)
    track.update(has_test_runner: false)
    refute exercise.has_test_runner?
  end

  test "enqueues head test runs job when there are testable files" do
    # Simulate testable files
    Git::Exercise::CheckForTestableChangesBetweenVersions.expects(:call).returns(true)

    exercise = create :practice_exercise, git_sha: '0b04b8976650d993ecf4603cf7413f3c6b898eff'

    assert_enqueued_with(job: MandateJob, args: [Exercise::QueueSolutionHeadTestRuns.name, exercise]) do
      exercise.update!(git_important_files_hash: 'new-hash')
      perform_enqueued_jobs
    end
  end

  test "does not enqueue head test runs job when git_important_files_hash changes when exercise's synced commit contains magic marker" do # rubocop:disable Layout/LineLength
    exercise = create :practice_exercise, slug: 'satellite', git_sha: 'cfd8cf31bb9c90fd9160c82db69556a47f7c2a54'

    Exercise::QueueSolutionHeadTestRuns.expects(:defer).never

    exercise.update!(git_important_files_hash: 'new-hash')
  end

  test "does not enqueue head test runs job when git_important_files_hash does not change" do
    exercise = create :practice_exercise

    assert_no_enqueued_jobs only: MandateJob do
      exercise.update!(position: 2)
    end
  end

  test "recalculates important files hash with solutions when git_important_files_hash changes" do
    git_sha = '0b04b8976650d993ecf4603cf7413f3c6b898eff'
    exercise = create(:practice_exercise, git_sha:)

    Exercise::ProcessGitImportantFilesChanged.expects(:defer).with(exercise, exercise.git_important_files_hash, git_sha,
      exercise.slug).once

    exercise.update!(git_important_files_hash: 'new-hash')
  end

  test "recalculates important files hash with solutions when git_important_files_hash changes when exercise's synced commit contains magic marker" do # rubocop:disable Layout/LineLength
    git_sha = 'cfd8cf31bb9c90fd9160c82db69556a47f7c2a54'
    exercise = create(:practice_exercise, slug: 'satellite', git_sha:)

    Exercise::ProcessGitImportantFilesChanged.expects(:defer).with(exercise, exercise.git_important_files_hash, git_sha,
      exercise.slug).once

    exercise.update!(git_important_files_hash: 'new-hash')
  end

  test "does not recalculate important files hash with solutions when git_important_files_hash does not change" do
    exercise = create :practice_exercise

    Exercise::RecalculateImportantFilesHashWithSolutions.expects(:call).never

    exercise.update!(position: 2)
  end

  test "updates track num_exercises when created" do
    track = create :track
    Track::UpdateNumExercises.expects(:call).with(track)
    create :practice_exercise, track:
  end

  test "updates track num_exercises when deleted" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    Track::UpdateNumExercises.expects(:call).with(track)
    exercise.destroy
  end

  test "updates track num_exercises when status column changed" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    Track::UpdateNumExercises.expects(:call).with(track)
    exercise.update(status: :beta)
  end

  test "doesnt update track num_exercises when other column changed" do
    track = create :track
    exercise = create(:practice_exercise, track:)

    Track::UpdateNumExercises.expects(:call).with(track).never
    exercise.update(title: 'something')
  end

  test "queues trigger representation reruns for exercise job when representer version is updated" do
    exercise = create :practice_exercise

    assert_enqueued_with(job: MandateJob, args: [Submission::Representation::TriggerRerunsForExercise.name, exercise]) do
      exercise.update!(representer_version: 2)
    end
  end

  test "does not enqueue trigger representation reruns for exercise job when representer version is unchanged" do
    exercise = create :practice_exercise

    assert_no_enqueued_jobs(only: MandateJob) do
      exercise.update!(slug: 'test')
    end
  end

  test "deletes associated site updates" do
    concept_exercise = create :concept_exercise
    practice_exercise = create :practice_exercise

    ce_site_update = create :new_exercise_site_update, params: { exercise: concept_exercise }
    assert_equal concept_exercise, ce_site_update.exercise # Sanity

    pe_site_update = create :new_exercise_site_update, params: { exercise: practice_exercise }
    assert_equal practice_exercise, pe_site_update.exercise # Sanity

    concept_exercise.destroy

    refute ConceptExercise.where(id: concept_exercise.id).exists?
    refute SiteUpdate.where(id: ce_site_update.id).exists?
    assert PracticeExercise.where(id: practice_exercise.id).exists?
    assert SiteUpdate.where(id: pe_site_update.id).exists?

    practice_exercise.destroy

    refute ConceptExercise.where(id: concept_exercise.id).exists?
    refute SiteUpdate.where(id: ce_site_update.id).exists?
    refute PracticeExercise.where(id: practice_exercise.id).exists?
    refute SiteUpdate.where(id: pe_site_update.id).exists?
  end
end
