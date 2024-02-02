require "test_helper"

class Solution::PublishTest < ActiveSupport::TestCase
  test "sets solution and iteration as published" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution:, idx: 1
    other_iteration = create :iteration, solution:, idx: 2

    Solution::Publish.(solution, solution.user_track, 1)

    assert solution.reload.published?
    assert iteration.reload.published?
    refute other_iteration.reload.published?
  end

  test "all iterations are published if none are passed" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution:, idx: 1
    other_iteration = create :iteration, solution:, idx: 2

    Solution::Publish.(solution, solution.user_track, nil)

    assert solution.reload.published?
    assert iteration.reload.published?
    assert other_iteration.reload.published?
  end

  test "all iterations are published if incorrect is passed" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution:, idx: 1
    other_iteration = create :iteration, solution:, idx: 2

    Solution::Publish.(solution, solution.user_track, 5)

    assert solution.reload.published?
    assert iteration.reload.published?
    assert other_iteration.reload.published?
  end

  test "only does things once" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    create(:iteration, solution:)

    User::ReputationToken::Create.expects(:defer).once
    Solution::Publish.(solution, solution.user_track, nil)
    Solution::Publish.(solution, solution.user_track, nil)
  end

  test "sets solution num_loc to published iteration num_loc" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution:, idx: 1, num_loc: 33
    create :iteration, solution:, idx: 2, num_loc: 44

    Solution::Publish.(solution, solution.user_track, 1)

    assert iteration.num_loc, solution.num_loc
  end

  test "sets solution num_loc to latest iteration num_loc if publishing all iterations" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    create :iteration, solution:, idx: 1, num_loc: 33
    latest_iteration = create :iteration, solution:, idx: 2, num_loc: 44

    Solution::Publish.(solution, solution.user_track, nil)

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
      create(:iteration, solution:)

      User::ReputationToken::Create.expects(:defer).once.with(solution.user, :published_solution, solution:, level:)
      Solution::Publish.(solution, solution.user_track, nil)
    end
  end

  test "creates activity" do
    exercise = create :practice_exercise

    user = create :user
    create :user_track, user:, track: exercise.track
    solution = create(:practice_solution, user:, exercise:)
    iteration = create(:iteration, solution:)

    Solution::Publish.(solution, solution.user_track, iteration.idx)

    activity = User::Activities::PublishedExerciseActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
  end

  test "completes solution if not completed" do
    freeze_time do
      solution = create :practice_solution, completed_at: nil
      create :user_track, user: solution.user, track: solution.track
      create :iteration, solution:, idx: 1

      Solution::Publish.(solution, solution.user_track, 1)

      assert_equal Time.current, solution.reload.completed_at
    end
  end

  test "awards anybody_there badge" do
    Solution::PublishIteration.any_instance.stubs(:call)

    user = create :user

    # 4 hello worlds is not enough
    4.times do |idx|
      track = create :track, slug: "track_#{idx}"
      create :hello_world_solution, :completed, user:, track:
    end

    solution = create(:hello_world_solution, completed_at: nil, user:)
    create :user_track, user: solution.user, track: solution.track
    create :iteration, solution:, idx: 1

    perform_enqueued_jobs do
      Solution::Publish.(solution, solution.user_track, 1)
    end

    assert_includes user.reload.badges.map(&:class), Badges::AnybodyThereBadge
  end

  test "awards functional february badge when published five or more exercises in Functional February track" do
    Solution::PublishIteration.any_instance.stubs(:call)

    travel_to Time.utc(2022, 2, 24)

    track = create :track, slug: 'fsharp'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::FunctionalFebruaryBadge
  end

  test "awards mechanical march badge when published five or more exercises in Mechanical March track" do
    Solution::PublishIteration.any_instance.stubs(:call)

    travel_to Time.utc(2022, 3, 12)

    track = create :track, slug: 'rust'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::MechanicalMarchBadge
  end

  test "awards analytical april badge when published five or more exercises in an Analytical April track" do
    Solution::PublishIteration.any_instance.stubs(:call)

    travel_to Time.utc(2022, 4, 12)

    track = create :track, slug: 'python'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::AnalyticalAprilBadge
  end

  test "awards mind-shifting may badge when published five or more exercises in a Mind Shifting May track" do
    Solution::PublishIteration.any_instance.stubs(:call)

    travel_to Time.utc(2022, 5, 12)

    track = create :track, slug: 'unison'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::MindShiftingMayBadge
  end

  test "awards summer-of-sexps badge when published five or more exercises in a Summer of Sexps track" do
    Solution::PublishIteration.any_instance.stubs(:call)

    travel_to Time.utc(2022, 6, 12)

    track = create :track, slug: 'clojure'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::SummerOfSexpsBadge
  end

  test "awards jurassic-july badge when published five or more exercises in a Jurassic July track" do
    Solution::PublishIteration.any_instance.stubs(:call)

    travel_to Time.utc(2022, 7, 12)

    track = create :track, slug: 'fortran'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::JurassicJulyBadge
  end

  test "awards apps august badge when published five or more exercises in an Appy August track" do
    Solution::PublishIteration.any_instance.stubs(:call)

    travel_to Time.utc(2022, 8, 12)

    track = create :track, slug: 'kotlin'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::AppsAugustBadge
  end

  test "awards slimline september badge when published five or more exercises in a Slimline September track" do
    Solution::PublishIteration.any_instance.stubs(:call)

    travel_to Time.utc(2022, 9, 12)

    track = create :track, slug: 'jq'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::SlimlineSeptemberBadge
  end

  test "awards object-oriented october badge when published five or more exercises in an Object-oriented October track" do
    Solution::PublishIteration.any_instance.stubs(:call)

    travel_to Time.utc(2022, 10, 12)

    track = create :track, slug: 'csharp'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::ObjectOrientedOctoberBadge
  end

  test "awards nibbly november badge when published five or more exercises in an Nibbly November track" do
    travel_to Time.utc(2022, 11, 12)

    track = create :track, slug: 'wasm'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::NibblyNovemberBadge
  end

  test "awards december diversions badge when published five or more exercises in a December Diversions track" do
    travel_to Time.utc(2022, 12, 12)

    track = create :track, slug: 'wren'
    user = create :user
    user_track = create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    4.times do
      exercise = create(:practice_exercise, :random_slug, track:)
      create(:practice_solution, :published, user:, track:, exercise:)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, exercise:)
    create :iteration, solution:, idx: 1
    refute user.badges.present?

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::DecemberDiversionsBadge
  end

  test "awards completed 12 in 23 badge when published all featured exercises" do
    travel_to Time.utc(2023, 12, 25)

    user = create :user
    create :user_challenge, user:, challenge_id: '12in23'

    User::Challenges::FeaturedExercisesProgress12In23.featured_exercises.values.flatten.uniq.each do |track_slug|
      track = create(:track, slug: track_slug)
      create(:user_track, user:, track:)
    end

    User::Challenges::FeaturedExercisesProgress12In23.featured_exercises.to_a[0..-2].each do |(exercise_slug, track_slugs)|
      track = Track.for!(track_slugs.sample)
      exercise = create(:practice_exercise, track:, slug: exercise_slug)
      create(:practice_solution, :published, user:, track:, exercise:)
    end

    # Sanity check: don't award badge when not yet published all exercises
    perform_enqueued_jobs
    refute_includes user.reload.badges.map(&:class), Badges::Completed12In23Badge

    exercise_slug, track_slugs = User::Challenges::FeaturedExercisesProgress12In23.featured_exercises.to_a.last
    track = Track.for!(track_slugs.sample)
    exercise = create(:practice_exercise, track:, slug: exercise_slug)
    create(:practice_solution, :completed, user:, track:, exercise:)

    perform_enqueued_jobs
    refute_includes user.reload.badges.map(&:class), Badges::Completed12In23Badge

    perform_enqueued_jobs do
      Solution::Publish.(user.solutions.last, user.solutions.last.user_track, 1)
    end

    assert_includes user.reload.badges.map(&:class), Badges::Completed12In23Badge
  end

  test "awards polyglot badge" do
    travel_to Time.utc(2023, 6, 3)
    user = create :user

    create_list(:track, 11, :random_slug).each do |track|
      create_list(:practice_exercise, 5, track:) do |exercise|
        create(:practice_solution, :published, user:, track:, exercise:)
      end
    end

    track = create :track, :random_slug
    user_track = create(:user_track, user:, track:)

    create_list(:practice_exercise, 4, track:) do |exercise|
      create(:practice_solution, :published, user:, track:, exercise:)
    end

    exercise = create(:practice_exercise, :random_slug, track:)
    solution = create(:practice_solution, user:, track:, exercise:)
    create :iteration, solution:, idx: 1

    Solution::Publish.(solution, user_track, 1)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::PolyglotBadge
  end

  test "solution snippet updated to published iteration's snippet when single iteration is published" do
    solution = create :practice_solution, snippet: 'my snippet'
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution:, idx: 1, snippet: 'aaa'
    create :iteration, solution:, idx: 2, snippet: 'bbb'

    Solution::Publish.(solution, solution.user_track, 1)

    assert_equal iteration.snippet, solution.snippet
  end

  test "solution snippet updated to latest published iteration's snippet when all iterations are published" do
    solution = create :practice_solution, snippet: 'my snippet'
    create :user_track, user: solution.user, track: solution.track
    create :iteration, solution:, idx: 1, snippet: 'aaa'
    other_iteration = create :iteration, solution:, idx: 2, snippet: 'bbb'

    Solution::Publish.(solution, solution.user_track, nil)

    assert_equal other_iteration.snippet, solution.snippet
  end

  test "adds metric" do
    Solution::PublishIteration.any_instance.stubs(:call)

    track = create :track
    user = create :user
    exercise = create(:concept_exercise, track:)
    user_track = create(:user_track, user:, track:)
    solution = create(:concept_solution, :completed, user:, exercise:)
    create(:iteration, solution:)

    perform_enqueued_jobs do
      Solution::Publish.(solution, user_track, nil)
    end

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_instance_of Metrics::PublishSolutionMetric, metric
    assert_equal solution.published_at, metric.occurred_at
    assert_equal track, metric.track
    assert_equal user, metric.user
  end

  test "updates num_published_solutions" do
    Solution::PublishIteration.any_instance.stubs(:call)

    track = create :track
    user = create :user
    exercise = create(:concept_exercise, track:)
    user_track = create(:user_track, user:, track:)
    solution = create(:concept_solution, :completed, user:, exercise:)
    create(:iteration, solution:)

    assert_equal 0, exercise.num_published_solutions
    perform_enqueued_jobs do
      Solution::Publish.(solution, user_track, nil)
    end
    assert_equal 1, exercise.reload.num_published_solutions
  end

  test "updates user's num_published_solutions" do
    Solution::PublishIteration.any_instance.stubs(:call)

    track = create :track
    user = create :user
    exercise = create(:concept_exercise, track:)
    user_track = create(:user_track, user:, track:)
    solution = create(:concept_solution, :completed, user:, exercise:)
    create(:iteration, solution:)

    assert_user_data_cache_reset(user, :num_published_solutions, 1) do
      Solution::Publish.(solution, user_track, nil)
    end
  end

  test "calls out to change representation" do
    track = create :track
    user = create :user
    exercise = create(:concept_exercise, track:)
    user_track = create(:user_track, user:, track:)

    solution = create(:concept_solution, user:, exercise:)
    create(:iteration, solution:)

    Solution::UpdatePublishedExerciseRepresentation.expects(:call).with(solution)
    Solution::Publish.(solution, user_track, nil)
  end

  test "don't invalidate image in cloudfront" do
    Infrastructure::InvalidateCloudfrontItems.expects(:defer).never

    track = create :track
    user = create :user
    exercise = create(:concept_exercise, track:)
    user_track = create(:user_track, user:, track:)
    solution = create(:concept_solution, :completed, user:, exercise:)
    create(:iteration, solution:)

    Solution::Publish.(solution, user_track, nil)
  end
end
