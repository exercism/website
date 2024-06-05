require 'test_helper'

class Iteration::CreateTest < ActiveSupport::TestCase
  test "increments iteration" do
    solution = create :concept_solution

    it_1 = Iteration::Create.(solution, create(:submission, solution:))
    assert_equal 1, it_1.idx

    it_2 = Iteration::Create.(solution, create(:submission, solution:))
    assert_equal 2, it_2.idx

    it_3 = Iteration::Create.(solution, create(:submission, solution:))
    assert_equal 3, it_3.idx

    # Check different count for different solution
    other_solution = create :concept_solution
    it_4 = Iteration::Create.(other_solution, create(:submission, solution: other_solution))
    assert_equal 1, it_4.idx
  end

  test "returns existing in case of duplicate" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    first = Iteration::Create.(solution, submission)
    second = Iteration::Create.(solution, submission)
    assert_equal first, second
  end

  test "runs after_save hook" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    Iteration.any_instance.expects(:handle_after_save!)
    Iteration::Create.(solution, submission)
  end

  test "creates activity" do
    user = create :user
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:, user:)
    submission = create(:submission, solution:)

    iteration = Iteration::Create.(solution, submission)

    activity = User::Activities::SubmittedIterationActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
    assert_equal iteration, activity.iteration
  end

  test "enqueues snippet creation" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    Iteration::Create.(solution, submission)
    assert enqueued_jobs.find do |job|
      job["job_class"] == "MandateJob" &&
        job["arguments"][0] == "Iteration::GenerateSnippet"
    end
  end

  test "enqueues lines of code counter job" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    Iteration::Create.(solution, submission)
    assert enqueued_jobs.find do |job|
      job["job_class"] == "MandateJob" &&
        job["arguments"][0] == "Iteration::CountLinesOfCode"
    end
  end

  test "enqueues PublishIteration job" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    Iteration::Create.(solution, submission)
    assert enqueued_jobs.find do |job|
      job["job_class"] == "MandateJob" &&
        job["arguments"][0] == "Iteration::PublishIteration" &&
        job["arguments"][1] == solution &&
        job["arguments"][2] == solution.published_iteration_id
    end
  end

  test "starts test run if untested" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    Submission::TestRun::Init.expects(:call).with(submission)
    Iteration::Create.(solution, submission)
  end

  test "does not start test run if already running" do
    solution = create :concept_solution
    submission = create :submission, solution:, tests_status: :queued

    Submission::TestRun::Init.expects(:call).never
    Iteration::Create.(solution, submission)
  end

  test "do not run tests if there's no test runner" do
    exercise = create :concept_exercise, has_test_runner: false
    solution = create(:concept_solution, exercise:)
    submission = create(:submission, solution:)

    Submission::TestRun::Init.expects(:call).never
    Iteration::Create.(solution, submission)
  end

  test "does not create representation if representation was already queued" do
    track = create :track, has_representer: false
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, exercise:)
    submission = create(:submission, solution:, representation_status: :queued)

    Submission::Representation::Init.expects(:call).never
    Iteration::Create.(solution, submission)
  end

  test "creates representation if there's no representer" do
    track = create :track, has_representer: false
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, exercise:)
    submission = create(:submission, solution:)

    Submission::Representation::Init.expects(:call).once
    Iteration::Create.(solution, submission)
  end

  test "creates representation if there's a representer" do
    track = create :track, has_representer: true
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, exercise:)
    submission = create(:submission, solution:)

    Submission::Representation::Init.expects(:call).once
    Iteration::Create.(solution, submission)
  end

  test "creates representation if there's a representer but no test runner" do
    track = create :track, has_representer: true
    exercise = create(:concept_exercise, track:, has_test_runner: false)
    solution = create(:concept_solution, exercise:)
    submission = create(:submission, solution:)

    Submission::Representation::Init.expects(:call).once
    Iteration::Create.(solution, submission)
  end

  test "runs analysis if there's an analyzer but no test runner" do
    track = create :track, has_analyzer: true
    exercise = create(:concept_exercise, track:, has_test_runner: false)
    solution = create(:concept_solution, exercise:)
    submission = create(:submission, solution:)

    Submission::Analysis::Init.expects(:call).once
    Iteration::Create.(solution, submission)
  end

  test "do not analyze if there's no analyzer" do
    track = create :track, has_analyzer: false
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, exercise:)
    submission = create(:submission, solution:)

    Submission::Analysis::Init.expects(:call).never
    Iteration::Create.(solution, submission)
  end

  test "starts analysis and representation" do
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"

    filename_2 = "barfood.rb"
    content_2 = "something = :else"

    solution = create :concept_solution
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: filename_1, content: content_1
    create :submission_file, submission:, filename: filename_2, content: content_2

    job_id = SecureRandom.uuid
    SecureRandom.stubs(uuid: job_id)

    Submission::Representation::Init.expects(:call).with(submission)
    Submission::Analysis::Init.expects(:call).with(submission)

    Iteration::Create.(solution, submission)

    submission.reload
    assert :queued, submission.representation_status
    assert :queued, submission.analysis_status
  end

  test "updates solution" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    # Sanity checks
    solution.reload
    assert_equal :started, solution.status
    assert_nil solution.iteration_status
    assert_equal 0, solution.num_iterations

    Iteration::Create.(solution, submission)
    solution.reload
    assert_equal :iterated, solution.status
    assert_equal :testing, solution.iteration_status
    assert_equal 1, solution.num_iterations
  end

  test "updates solution for tested submission" do
    solution = create :concept_solution
    submission = create :submission, solution:, tests_status: :passed

    # Sanity checks
    solution.reload
    assert_equal :started, solution.status
    assert_nil solution.iteration_status
    assert_equal 0, solution.num_iterations

    Iteration::Create.(solution, submission)
    solution.reload
    assert_equal 'queued', submission.representation_status
    assert_equal 'queued', submission.analysis_status
    assert_equal :iterated, solution.status
    assert_equal :analyzing, solution.iteration_status
    assert_equal 1, solution.num_iterations
  end

  test "schedules notifications" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    assert_enqueued_with(job: ProcessIterationForDiscussionsJob) do
      Iteration::Create.(solution, submission)
    end
  end

  test "awards die unendliche geschichte badge when submitting 10th iteration" do
    user = create :user
    solution = create(:concept_solution, user:)

    perform_enqueued_jobs do
      9.times do |_idx|
        submission = create(:submission, solution:)
        Iteration::Create.(solution, submission)
      end

      refute user.badges.present?

      submission = create(:submission, solution:)
      Iteration::Create.(solution, submission)

      assert_includes user.reload.badges.map(&:class), Badges::DieUnendlicheGeschichteBadge
    end
  end

  test "awards growth mindset badge when solution has mentor discussion" do
    user = create :user
    solution = create(:concept_solution, user:)
    submission_1 = create(:submission, solution:)
    Iteration::Create.(solution, submission_1)
    perform_enqueued_jobs

    # Sanity check: no discussion present
    assert_empty User::AcquiredBadge.where(user: user.reload, badge: Badges::GrowthMindsetBadge)

    create :mentor_discussion, solution: solution.reload
    submission_2 = create(:submission, solution:)
    Iteration::Create.(solution, submission_2)
    perform_enqueued_jobs

    # Sanity check: discussion present, but no iteration after creation of discussion
    assert_empty User::AcquiredBadge.where(user: user.reload, badge: Badges::GrowthMindsetBadge)

    travel 1.day do
      submission_3 = create(:submission, solution:)
      Iteration::Create.(solution.reload, submission_3)
      perform_enqueued_jobs
    end

    assert_includes user.reload.badges.map(&:class), Badges::GrowthMindsetBadge
  end

  test "awards 12in23 badge when iterating five or more exercises in a track after participating in 12in23 challenge" do
    track = create :track
    user = create :user
    create(:user_track, user:, track:)

    create :user_challenge, user:, challenge_id: '12in23'

    # Ignore old iteration
    travel_to Time.utc(2022, 7, 1)
    exercise = create(:practice_exercise, slug: "leap", track:)
    solution = create(:practice_solution, user:, track:, exercise:)
    submission = create(:submission, solution:)
    Iteration::Create.(solution, submission)

    travel_to Time.utc(2023, 2, 4)
    %w[allergies anagram bob hamming].each do |slug|
      exercise = create(:practice_exercise, slug:, track:)
      solution = create(:practice_solution, user:, track:, exercise:)
      submission = create(:submission, solution:)
      Iteration::Create.(solution, submission)
      refute user.badges.present?
    end

    exercise = create(:practice_exercise, slug: "leap", track:)
    solution = create(:practice_solution, user:, track:, exercise:)
    submission = create(:submission, solution:)
    Iteration::Create.(solution, submission)

    perform_enqueued_jobs
    assert_includes user.reload.badges.map(&:class), Badges::ParticipantIn12In23Badge
  end

  test "updates created iteration's num_loc" do
    user = create :user
    solution = create(:concept_solution, user:)
    submission = create(:submission, solution:)
    create(:submission_file, submission:)

    stub_request(:post, Exercism.config.snippet_generator_url)
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: submission.track.slug,
          submission_uuid: submission.uuid,
          submission_filepaths: submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":77,\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {})

    iteration = Iteration::Create.(solution, submission)
    perform_enqueued_jobs

    assert_equal 77, iteration.reload.num_loc
  end

  test "updates solution num_loc to created iteration's num_loc when solution is unpublished" do
    user = create :user
    solution = create(:concept_solution, user:)
    submission = create(:submission, solution:)
    create(:submission_file, submission:)

    stub_request(:post, Exercism.config.snippet_generator_url)
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: submission.track.slug,
          submission_uuid: submission.uuid,
          submission_filepaths: submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":77,\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {})

    perform_enqueued_jobs do
      Iteration::Create.(solution, submission)
    end

    assert_equal 77, solution.reload.num_loc
  end

  test "updates solution num_loc to created iteration's num_loc when all iterations are published" do
    user = create :user
    solution = create(:concept_solution, :published, user:)
    submission = create(:submission, solution:)
    create(:submission_file, submission:)

    stub_request(:post, Exercism.config.snippet_generator_url)
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: submission.track.slug,
          submission_uuid: submission.uuid,
          submission_filepaths: submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":77,\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {})

    perform_enqueued_jobs do
      Iteration::Create.(solution, submission)
    end

    assert_equal 77, solution.reload.num_loc
  end

  test "does not update solution num_loc when other iteration is published" do
    user = create :user
    solution = create(:concept_solution, user:)
    published_iteration = create :iteration, solution:, num_loc: 77
    solution.update!(num_loc: published_iteration.num_loc, published_iteration:, published_at: Time.current)
    submission = create(:submission, solution:)
    create(:submission_file, submission:)

    stub_request(:post, Exercism.config.snippet_generator_url)
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: submission.track.slug,
          submission_uuid: submission.uuid,
          submission_filepaths: submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":13,\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {})

    perform_enqueued_jobs do
      Iteration::Create.(solution, submission)
    end

    assert_equal published_iteration.num_loc, solution.reload.num_loc
  end

  test "awards new years resolution badge when created on January 1st" do
    user = create :user
    track = create :track
    solution = create(:concept_solution, track:, user:)

    travel_to(Time.utc(2019, 1, 1, 0, 0, 0))

    perform_enqueued_jobs do
      Iteration::Create.(solution, create(:submission, solution:, user:))
    end

    assert_includes user.reload.badges.map(&:class), Badges::NewYearsResolutionBadge
  end

  test "adds metric" do
    solution = create :concept_solution
    submission = create(:submission, solution:)

    iteration = Iteration::Create.(solution, submission)
    perform_enqueued_jobs

    assert_equal 1, Metric.count
    metric = Metric.last
    assert_instance_of Metrics::SubmitIterationMetric, metric
    assert_equal iteration.created_at, metric.occurred_at
    assert_equal iteration, metric.iteration
    assert_equal iteration.track, metric.track
    assert_equal solution.user, metric.user
  end

  test "awards trophy when now having iterated twenty exercises" do
    user = create :user
    track = create :track
    create(:user_track, user:, track:)

    create_list(:practice_solution, 19, user:, track:) do |solution|
      create_list(:submission, 2, solution:) do |submission|
        create(:iteration, submission:)
      end
    end

    refute_includes user.reload.trophies.map(&:class), Track::Trophies::IteratedTwentyExercisesTrophy

    solution = create(:practice_solution, user:, track:)
    submission_1 = create(:submission, solution:)
    create(:iteration, submission: submission_1)

    submission_2 = create(:submission, solution:)
    perform_enqueued_jobs do
      Iteration::Create.(solution, submission_2)
    end

    assert_includes user.reload.trophies.map(&:class), Track::Trophies::IteratedTwentyExercisesTrophy
  end
end
