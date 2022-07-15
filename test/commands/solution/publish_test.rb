require "test_helper"

class Solution::PublishTest < ActiveSupport::TestCase
  test "sets solution and iteration as published" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2

    Solution::Publish.(solution, solution.user_track, 1, 'DK')

    assert solution.reload.published?
    assert iteration.reload.published?
    refute other_iteration.reload.published?
  end

  test "all iterations are published if none are passed" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2

    Solution::Publish.(solution, solution.user_track, nil, 'DK')

    assert solution.reload.published?
    assert iteration.reload.published?
    assert other_iteration.reload.published?
  end

  test "all iterations are published if incorrect is passed" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution: solution, idx: 1
    other_iteration = create :iteration, solution: solution, idx: 2

    Solution::Publish.(solution, solution.user_track, 5, 'DK')

    assert solution.reload.published?
    assert iteration.reload.published?
    assert other_iteration.reload.published?
  end

  test "only does things once" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    create :iteration, solution: solution

    AwardReputationTokenJob.expects(:perform_later).once
    Solution::Publish.(solution, solution.user_track, nil, 'DK')
    Solution::Publish.(solution, solution.user_track, nil, 'DK')
  end

  test "sets solution num_loc to published iteration num_loc" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution: solution, idx: 1, num_loc: 33
    create :iteration, solution: solution, idx: 2, num_loc: 44

    Solution::Publish.(solution, solution.user_track, 1, 'DK')

    assert iteration.num_loc, solution.num_loc
  end

  test "sets solution num_loc to latest iteration num_loc if publishing all iterations" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    create :iteration, solution: solution, idx: 1, num_loc: 33
    latest_iteration = create :iteration, solution: solution, idx: 2, num_loc: 44

    Solution::Publish.(solution, solution.user_track, nil, 'DK')

    assert latest_iteration.num_loc, solution.num_loc
  end

  test "awards level correctly" do
    easy_solution = create :practice_solution, exercise: create(:practice_exercise, :random_slug, difficulty: 1)
    medium_solution = create :practice_solution, exercise: create(:practice_exercise, :random_slug, difficulty: 5)
    hard_solution = create :practice_solution, exercise: create(:practice_exercise, :random_slug, difficulty: 9)
    concept_solution = create :concept_solution

    {
      easy_solution => :easy,
      medium_solution => :medium,
      hard_solution => :hard,
      concept_solution => :concept
    }.each do |solution, level|
      create :user_track, user: solution.user, track: solution.track
      create :iteration, solution: solution

      AwardReputationTokenJob.expects(:perform_later).once.with(solution.user, :published_solution, solution:, level:)
      Solution::Publish.(solution, solution.user_track, nil, 'DK')
    end
  end

  test "creates activity" do
    exercise = create :practice_exercise

    user = create :user
    create :user_track, user: user, track: exercise.track
    solution = create :practice_solution, user: user, exercise: exercise
    iteration = create :iteration, solution: solution

    Solution::Publish.(solution, solution.user_track, iteration.idx, 'DK')

    activity = User::Activities::PublishedExerciseActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
  end

  test "completes solution if not completed" do
    freeze_time do
      solution = create :practice_solution, completed_at: nil
      create :user_track, user: solution.user, track: solution.track
      create :iteration, solution: solution, idx: 1

      Solution::Publish.(solution, solution.user_track, 1, 'DK')

      assert_equal Time.current, solution.reload.completed_at
    end
  end

  test "awards anybody_there badge" do
    user = create :user

    # 4 hello worlds is not enough
    4.times do |idx|
      track = create :track, slug: "track_#{idx}"
      create :hello_world_solution, :completed, user:, track:
    end

    solution = create :hello_world_solution, completed_at: nil, user: user
    create :user_track, user: solution.user, track: solution.track
    create :iteration, solution: solution, idx: 1

    Solution::Publish.(solution, solution.user_track, 1, 'DK')

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::AnybodyThereBadge
  end

  test "solution snippet updated to published iteration's snippet when single iteration is published" do
    solution = create :practice_solution, snippet: 'my snippet'
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution: solution, idx: 1, snippet: 'aaa'
    create :iteration, solution: solution, idx: 2, snippet: 'bbb'

    Solution::Publish.(solution, solution.user_track, 1, 'DK')

    assert_equal iteration.snippet, solution.snippet
  end

  test "solution snippet updated to latest published iteration's snippet when all iterations are published" do
    solution = create :practice_solution, snippet: 'my snippet'
    create :user_track, user: solution.user, track: solution.track
    create :iteration, solution: solution, idx: 1, snippet: 'aaa'
    other_iteration = create :iteration, solution: solution, idx: 2, snippet: 'bbb'

    Solution::Publish.(solution, solution.user_track, nil, 'DK')

    assert_equal other_iteration.snippet, solution.snippet
  end

  test "adds metric" do
    track = create :track
    user = create :user
    exercise = create :concept_exercise, track: track
    user_track = create :user_track, user: user, track: track
    solution = create :concept_solution, :completed, user: user, exercise: exercise
    create :iteration, solution: solution

    Solution::Publish.(solution, user_track, nil, 'DK')
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_equal Metrics::PublishSolutionMetric, metric.class
    assert_equal solution.published_at, metric.occurred_at
    assert_equal track, metric.track
    assert_equal user, metric.user
  end
end
