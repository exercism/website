require "test_helper"

class Solution::CompleteTest < ActiveSupport::TestCase
  test "sets concept exercise solution as completed" do
    exercise = create :concept_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :concept_solution, user: user, exercise: exercise
    create :iteration, solution: solution

    Solution::Complete.(solution, user_track, 'ZA')

    assert solution.reload.completed?
  end

  test "sets concept exercise concepts as learnt" do
    track = create :track
    concept = create :concept, track: track
    exercise = create :concept_exercise, track: track
    exercise.taught_concepts << concept

    user = create :user
    user_track = create :user_track, user: user, track: track
    solution = create :concept_solution, user: user, exercise: exercise
    submission = create :submission, solution: solution
    create :iteration, submission: submission

    Solution::Complete.(solution, user_track, 'ZA')

    assert user_track.concept_learnt?(concept)
  end

  test "sets practice exercise solution as completed" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    create :iteration, solution: solution

    Solution::Complete.(solution, user_track, 'ZA')

    assert solution.reload.completed?
  end

  test "creates activity" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    create :iteration, solution: solution

    Solution::Complete.(solution, user_track, 'ZA')

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
      user_track = create :user_track, user: user, track: exercise.track
      solution = create :concept_solution, user: user, exercise: exercise, completed_at: completed_at
      create :iteration, solution: solution

      # Sanity check
      assert solution.completed?

      Solution::Complete.(solution, user_track, 'ZA')

      solution.reload
      assert solution.completed?
      assert_equal completed_at, solution.completed_at
      refute User::Activities::CompletedExerciseActivity.exists?
    end
  end

  test "raises when solution has no iterations" do
    exercise = create :practice_exercise

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise

    assert_raises SolutionHasNoIterationsError do
      Solution::Complete.(solution, user_track, 'ZA')
    end
  end

  test "awards anybody there badge when hello-world exercise is completed in five tracks" do
    user = create :user
    user_track = create :user_track, user: user
    solution = create :hello_world_solution, user: user
    create :iteration, solution: solution
    refute user.badges.present?

    4.times do |idx|
      track = create :track, slug: "track_#{idx}"
      create :hello_world_solution, :completed, user:, track:
    end

    Solution::Complete.(solution, user_track, 'ZA')

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::AnybodyThereBadge
  end

  test "awards all your base badge when all-your-base exercise is completed" do
    exercise = create :practice_exercise, slug: 'all-your-base'

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    create :iteration, solution: solution
    refute user.badges.present?

    Solution::Complete.(solution, user_track, 'ZA')

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::AllYourBaseBadge
  end

  test "awards whatever badge when bob exercise is completed" do
    exercise = create :practice_exercise, slug: 'bob'

    user = create :user
    user_track = create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    create :iteration, solution: solution
    refute user.badges.present?

    Solution::Complete.(solution, user_track, 'ZA')

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::WhateverBadge
  end

  test "awards lackadaisical badge when bob exercise is completed in five tracks" do
    user = create :user
    track = create :track
    user_track = create :user_track, user: user, track: track
    refute user.badges.present?

    exercise = create :practice_exercise, slug: 'bob'
    solution = create :practice_solution, user: user, track: track, exercise: exercise
    create :iteration, solution: solution

    4.times do |idx|
      other_track = create :track, slug: "track_#{idx}"
      exercise = create :practice_exercise, slug: 'bob', track: other_track
      create :practice_solution, :completed, user:, track: other_track, exercise:
    end

    Solution::Complete.(solution, user_track, 'ZA')

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::LackadaisicalBadge
  end

  test "awards completer badge when all the track's exercises are now completed" do
    user = create :user
    track = create :track
    create :hello_world_exercise, track: track
    concept_exercise = create :concept_exercise, track: track, position: 1
    practice_exercise = create :practice_exercise, track: track, position: 2, slug: 'leap'
    user_track = create :user_track, user: user, track: track
    refute user.badges.present?

    create :hello_world_solution, :completed, user: user, track: track
    create :concept_solution, :completed, user: user, track: track, exercise: concept_exercise
    refute user.reload.badges.present?

    solution = create :practice_solution, user: user, track: track, exercise: practice_exercise
    create :iteration, solution: solution

    Solution::Complete.(solution, user_track, 'ZA')

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::CompleterBadge
  end

  test "awards conceptual badge when all the track's learning exercises are now completed" do
    user = create :user
    track = create :track
    create :hello_world_exercise, track: track
    concept_exercise = create :concept_exercise, track: track, position: 1
    practice_exercise = create :practice_exercise, track: track, position: 2, slug: 'leap'
    user_track = create :user_track, user: user, track: track
    refute user.badges.present?

    create :hello_world_solution, :completed, user: user, track: track
    create :practice_solution, :completed, user: user, track: track, exercise: practice_exercise
    refute user.reload.badges.present?

    solution = create :concept_solution, user: user, track: track, exercise: concept_exercise
    create :iteration, solution: solution

    Solution::Complete.(solution, user_track, 'ZA')

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::ConceptualBadge
  end

  test "adds metric" do
    track = create :track
    user = create :user
    exercise = create :concept_exercise, track: track
    user_track = create :user_track, user: user, track: track
    solution = create :concept_solution, user: user, exercise: exercise
    create :iteration, solution: solution

    Solution::Complete.(solution, user_track, 'ZA')
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_equal Metrics::CompleteSolutionMetric, metric.class
    assert_equal solution.completed_at, metric.occurred_at
    assert_equal track, metric.track
    assert_equal user, metric.user
  end
end
