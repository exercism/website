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
    submission = create :submission, solution: solution

    first = Iteration::Create.(solution, submission)
    second = Iteration::Create.(solution, submission)
    assert_equal first, second
  end

  test "runs after_save hook" do
    solution = create :concept_solution
    submission = create :submission, solution: solution

    Iteration.any_instance.expects(:handle_after_save!)
    Iteration::Create.(solution, submission)
  end

  test "creates activity" do
    user = create :user
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise, user: user
    submission = create :submission, solution: solution

    iteration = Iteration::Create.(solution, submission)

    activity = User::Activities::SubmittedIterationActivity.last
    assert_equal user, activity.user
    assert_equal exercise.track, activity.track
    assert_equal solution, activity.solution
    assert_equal iteration, activity.iteration
  end

  test "enqueues snippet job" do
    solution = create :concept_solution
    submission = create :submission, solution: solution

    assert_enqueued_with job: GenerateIterationSnippetJob do
      Iteration::Create.(solution, submission)
    end
  end

  test "enqueues lines of code counter job" do
    solution = create :concept_solution
    submission = create :submission, solution: solution

    assert_enqueued_with job: CalculateLinesOfCodeJob do
      Iteration::Create.(solution, submission)
    end
  end

  test "starts test run if untested" do
    solution = create :concept_solution
    submission = create :submission, solution: solution

    Submission::TestRun::Init.expects(:call).with(submission)
    Iteration::Create.(solution, submission)
  end

  test "does not start test run if already running" do
    solution = create :concept_solution
    submission = create :submission, solution: solution, tests_status: :queued

    Submission::TestRun::Init.expects(:call).never
    Iteration::Create.(solution, submission)
  end

  test "do not run tests if there's no test runner" do
    exercise = create :concept_exercise, has_test_runner: false
    solution = create :concept_solution, exercise: exercise
    submission = create :submission, solution: solution

    Submission::TestRun::Init.expects(:call).never
    Iteration::Create.(solution, submission)
  end

  test "do not create representation if there's no representer" do
    track = create :track, has_representer: false
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise
    submission = create :submission, solution: solution

    Submission::Representation::Init.expects(:call).never
    Iteration::Create.(solution, submission)
  end

  test "do not analyze if there's no analyzer" do
    track = create :track, has_analyzer: false
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, exercise: exercise
    submission = create :submission, solution: solution

    Submission::Analysis::Init.expects(:call).never
    Iteration::Create.(solution, submission)
  end

  test "starts analysis and representation" do
    filename_1 = "subdir/foobar.rb"
    content_1 = "'I think' = 'I am'"

    filename_2 = "barfood.rb"
    content_2 = "something = :else"

    solution = create :concept_solution
    submission = create :submission, solution: solution
    create :submission_file, submission: submission, filename: filename_1, content: content_1
    create :submission_file, submission: submission, filename: filename_2, content: content_2

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
    submission = create :submission, solution: solution

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
    submission = create :submission, solution: solution, tests_status: :passed

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
    submission = create :submission, solution: solution

    assert_enqueued_with(job: ProcessIterationForDiscussionsJob) do
      Iteration::Create.(solution, submission)
    end
  end

  test "awards die unendliche geschichte badge when submitting 10th iteration" do
    user = create :user
    solution = create :concept_solution, user: user

    perform_enqueued_jobs do
      9.times do |_idx|
        submission = create :submission, solution: solution
        Iteration::Create.(solution, submission)
      end

      refute user.badges.present?

      submission = create :submission, solution: solution
      Iteration::Create.(solution, submission)

      assert_includes user.reload.badges.map(&:class), Badges::DieUnendlicheGeschichteBadge
    end
  end

  test "awards growth mindset badge when solution has mentor discussion" do
    user = create :user
    solution = create :concept_solution, user: user
    submission_1 = create :submission, solution: solution
    Iteration::Create.(solution, submission_1)
    perform_enqueued_jobs

    # Sanity check: no discussion present
    assert_empty User::AcquiredBadge.where(user: user.reload, badge: Badges::GrowthMindsetBadge)

    create :mentor_discussion, solution: solution.reload
    submission_2 = create :submission, solution: solution
    Iteration::Create.(solution, submission_2)
    perform_enqueued_jobs

    # Sanity check: discussion present, but no iteration after creation of discussion
    assert_empty User::AcquiredBadge.where(user: user.reload, badge: Badges::GrowthMindsetBadge)

    travel 1.day do
      submission_3 = create :submission, solution: solution
      Iteration::Create.(solution.reload, submission_3)
      perform_enqueued_jobs
    end

    assert_includes user.reload.badges.map(&:class), Badges::GrowthMindsetBadge
  end

  test "updates created iteration's num_loc" do
    user = create :user
    solution = create :concept_solution, user: user
    submission = create :submission, solution: solution
    create :submission_file, submission: submission

    stub_request(:post, Exercism.config.snippet_generator_url)
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: submission.track.slug,
          submission_uuid: submission.uuid,
          submission_filepaths: submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":77,\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    iteration = Iteration::Create.(solution, submission)
    perform_enqueued_jobs

    assert_equal 77, iteration.reload.num_loc
  end

  test "updates solution num_loc to created iteration's num_loc when solution is unpublished" do
    user = create :user
    solution = create :concept_solution, user: user
    submission = create :submission, solution: solution
    create :submission_file, submission: submission

    stub_request(:post, Exercism.config.snippet_generator_url)
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: submission.track.slug,
          submission_uuid: submission.uuid,
          submission_filepaths: submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":77,\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    perform_enqueued_jobs do
      Iteration::Create.(solution, submission)
    end

    assert_equal 77, solution.reload.num_loc
  end

  test "updates solution num_loc to created iteration's num_loc when all iterations are published" do
    user = create :user
    solution = create :concept_solution, :published, user: user
    submission = create :submission, solution: solution
    create :submission_file, submission: submission

    stub_request(:post, Exercism.config.snippet_generator_url)
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: submission.track.slug,
          submission_uuid: submission.uuid,
          submission_filepaths: submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":77,\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    perform_enqueued_jobs do
      Iteration::Create.(solution, submission)
    end

    assert_equal 77, solution.reload.num_loc
  end

  test "does not update solution num_loc when other iteration is published" do
    user = create :user
    solution = create :concept_solution, user: user
    published_iteration = create :iteration, solution: solution, num_loc: 77
    solution.update!(num_loc: published_iteration.num_loc, published_iteration:, published_at: Time.current)
    submission = create :submission, solution: solution
    create :submission_file, submission: submission

    stub_request(:post, Exercism.config.snippet_generator_url)
    stub_request(:post, Exercism.config.lines_of_code_counter_url).
      with(
        body: {
          track_slug: submission.track.slug,
          submission_uuid: submission.uuid,
          submission_filepaths: submission.valid_filepaths
        }.to_json
      ).
      to_return(status: 200, body: "{\"counts\":{\"code\":13,\"blanks\":9,\"comments\":0},\"files\":[\"Anagram.fs\"]}", headers: {}) # rubocop:disable Layout/LineLength

    perform_enqueued_jobs do
      Iteration::Create.(solution, submission)
    end

    assert_equal published_iteration.num_loc, solution.reload.num_loc
  end
end
