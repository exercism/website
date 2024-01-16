require "test_helper"

class Solution::CompleteTest < ActiveSupport::TestCase
  test "sets concept exercise solution as completed" do
    exercise = create :concept_exercise

    user = create :user
    user_track = create :user_track, user:, track: exercise.track
    solution = create(:concept_solution, user:, exercise:)
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)

    assert solution.reload.completed?
  end

  test "sets concept exercise concepts as learnt" do
    track = create :track
    concept = create(:concept, track:)
    exercise = create(:concept_exercise, track:)
    exercise.taught_concepts << concept

    user = create :user
    user_track = create(:user_track, user:, track:)
    solution = create(:concept_solution, user:, exercise:)
    submission = create(:submission, solution:)
    create(:iteration, submission:)

    Solution::Complete.(solution, user_track)

    assert user_track.concept_learnt?(concept)
  end

  test "sets practice exercise solution as completed" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user:, track: exercise.track
    solution = create(:practice_solution, user:, exercise:)
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)

    assert solution.reload.completed?
  end

  test "creates activity" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user:, track: exercise.track
    solution = create(:practice_solution, user:, exercise:)
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)

    activity = User::Activities::CompletedExerciseActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
  end

  test "does nothing when solution has already been completed" do
    freeze_time do
      exercise = create :concept_exercise
      completed_at = Time.current - 5.minutes

      user = create :user
      user_track = create :user_track, user:, track: exercise.track
      solution = create(:concept_solution, user:, exercise:, completed_at:)
      create(:iteration, solution:)

      # Sanity check
      assert solution.completed?

      Solution::Complete.(solution, user_track)

      solution.reload
      assert solution.completed?
      assert_equal completed_at, solution.completed_at
      refute User::Activities::CompletedExerciseActivity.exists?
    end
  end

  test "raises when solution has no iterations" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user:, track: exercise.track
    solution = create(:practice_solution, user:, exercise:)

    assert_raises SolutionHasNoIterationsError do
      Solution::Complete.(solution, user_track)
    end
  end

  test "awards anybody there badge when hello-world exercise is completed in five tracks" do
    user = create :user
    user_track = create(:user_track, user:)
    solution = create(:hello_world_solution, user:)
    create(:iteration, solution:)
    refute user.badges.present?

    4.times do |idx|
      track = create :track, slug: "track_#{idx}"
      create :hello_world_solution, :completed, user:, track:
    end

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::AnybodyThereBadge
  end

  test "awards all your base badge when all-your-base exercise is completed" do
    exercise = create :practice_exercise, slug: 'all-your-base'

    user = create :user
    user_track = create :user_track, user:, track: exercise.track
    solution = create(:practice_solution, user:, exercise:)
    create(:iteration, solution:)
    refute user.badges.present?

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::AllYourBaseBadge
  end

  test "awards whatever badge when bob exercise is completed" do
    exercise = create :practice_exercise, slug: 'bob'

    user = create :user
    user_track = create :user_track, user:, track: exercise.track
    solution = create(:practice_solution, user:, exercise:)
    create(:iteration, solution:)
    refute user.badges.present?

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::WhateverBadge
  end

  test "awards lackadaisical badge when bob exercise is completed in five tracks" do
    user = create :user
    track = create :track
    user_track = create(:user_track, user:, track:)
    refute user.badges.present?

    exercise = create :practice_exercise, slug: 'bob'
    solution = create(:practice_solution, user:, track:, exercise:)
    create(:iteration, solution:)

    4.times do |idx|
      other_track = create :track, slug: "track_#{idx}"
      exercise = create :practice_exercise, slug: 'bob', track: other_track
      create :practice_solution, :completed, user:, track: other_track, exercise:
    end

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::LackadaisicalBadge
  end

  test "awards completer badge when all the track's exercises are now completed" do
    user = create :user
    track = create :track
    create(:hello_world_exercise, track:)
    concept_exercise = create :concept_exercise, track:, position: 1
    practice_exercise = create :practice_exercise, track:, position: 2, slug: 'leap'
    user_track = create(:user_track, user:, track:)
    refute user.badges.present?

    create(:hello_world_solution, :completed, user:, track:)
    create :concept_solution, :completed, user:, track:, exercise: concept_exercise
    refute user.reload.badges.present?

    solution = create :practice_solution, user:, track:, exercise: practice_exercise
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::CompleterBadge
  end

  test "awards conceptual badge when all the track's learning exercises are now completed" do
    user = create :user
    track = create :track
    create(:hello_world_exercise, track:)
    concept_exercise = create :concept_exercise, track:, position: 1
    practice_exercise = create :practice_exercise, track:, position: 2, slug: 'leap'
    user_track = create(:user_track, user:, track:)
    refute user.badges.present?

    create(:hello_world_solution, :completed, user:, track:)
    create :practice_solution, :completed, user:, track:, exercise: practice_exercise
    refute user.reload.badges.present?

    solution = create :concept_solution, user:, track:, exercise: concept_exercise
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::ConceptualBadge
  end

  test "awards completed all exercises trophy when all the track's learning exercises are now completed" do
    user = create :user
    track = create :track
    create(:hello_world_exercise, track:)
    concept_exercise = create :concept_exercise, track:, position: 1
    practice_exercise = create :practice_exercise, track:, position: 2, slug: 'leap'
    user_track = create(:user_track, user:, track:)
    refute user.badges.present?

    create(:hello_world_solution, :completed, user:, track:)
    create :practice_solution, :completed, user:, track:, exercise: practice_exercise
    refute user.reload.badges.present?

    solution = create :concept_solution, user:, track:, exercise: concept_exercise
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.trophies.map(&:class), Track::Trophies::CompletedAllExercisesTrophy
  end

  test "awards completed 50% of exercises trophy when at least 50% of the track exercises are now completed" do
    user = create :user
    track = create :track
    create(:hello_world_exercise, track:)
    create :concept_exercise, track:, position: 1
    practice_exercise = create :practice_exercise, track:, position: 2, slug: 'leap'
    create(:user_track, user:, track:)
    refute user.badges.present?

    # We need to get hold of the user track like this as otherwise
    # we'd end up with the code being tested using a different,
    # cached version of the user track and we could not reset the
    # summary data
    user_track = UserTrack.for!(user, track)

    create(:hello_world_solution, :completed, user:, track:)
    refute user.reload.badges.present?

    solution = create :practice_solution, user:, track:, exercise: practice_exercise
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    user_track.reset_summary!
    assert_includes user.reload.trophies.map(&:class), Track::Trophies::CompletedFiftyPercentOfExercisesTrophy
  end

  test "awards completed twenty exercises trophy when completing 20th exercise" do
    user = create :user
    track = create :track
    practice_exercises = create_list(:practice_exercise, 25, :random_slug, track:, difficulty: 9)
    user_track = create(:user_track, user:, track:)
    refute user.badges.present?

    practice_exercises[0..18].each do |exercise|
      create(:practice_solution, :completed, user:, track:, exercise:)
      refute user.reload.badges.present?
    end

    solution = create :practice_solution, user:, track:, exercise: practice_exercises[19]
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.trophies.map(&:class), Track::Trophies::CompletedTwentyExercisesTrophy
  end

  test "awards completed five hard exercises trophy when completing fifth hard exercise" do
    user = create :user
    track = create :track
    create(:hello_world_exercise, track:)
    practice_exercises = create_list(:practice_exercise, 6, :random_slug, track:, difficulty: 9)
    user_track = create(:user_track, user:, track:)
    refute user.badges.present?

    create(:hello_world_solution, :completed, user:, track:)

    practice_exercises[0..3].each do |exercise|
      create(:practice_solution, :completed, user:, track:, exercise:)
      refute user.reload.badges.present?
    end

    solution = create :practice_solution, user:, track:, exercise: practice_exercises[4]
    create(:iteration, solution:)

    trophy = create :completed_five_hard_exercises_trophy
    trophy.reseed!

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.trophies.map(&:class), Track::Trophies::CompletedFiveHardExercisesTrophy
  end

  test "awards completed learning mode trophy when all the track's learning exercises are now completed" do
    user = create :user
    track = create :track
    create(:hello_world_exercise, track:)
    concept_exercise = create :concept_exercise, track:, position: 1
    create :practice_exercise, track:, position: 2, slug: 'leap'
    user_track = create(:user_track, user:, track:)
    refute user.badges.present?

    solution = create :concept_solution, user:, track:, exercise: concept_exercise
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)

    perform_enqueued_jobs
    assert_includes user.reload.trophies.map(&:class), Track::Trophies::CompletedLearningModeTrophy
  end

  test "adds metric" do
    track = create :track
    user = create :user
    exercise = create(:concept_exercise, track:)
    user_track = create(:user_track, user:, track:)
    solution = create(:concept_solution, user:, exercise:)
    create(:iteration, solution:)

    Solution::Complete.(solution, user_track)
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_instance_of Metrics::CompleteSolutionMetric, metric
    assert_equal solution.completed_at, metric.occurred_at
    assert_equal track, metric.track
    assert_equal user, metric.user
  end
end
