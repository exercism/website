require 'test_helper'

class Submission::Representation::GenerateTest < ActiveSupport::TestCase
  test "posts the solution and exercise files to the representer" do
    solution = create :concept_solution
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "log_line_parser.rb", content: "class LogLineParser\nend"
    create :submission_file, submission:, filename: "subdir/new_file.rb", content: "new file"
    create :submission_file, submission:, filename: "log_line_parser_test.rb", content: "Don't override tests"
    create :submission_file, submission:, filename: ".meta/config.json", content: "Don't allow meta"

    stub_request(:post, Exercism.config.representer_url).
      with do |request|
        body = JSON.parse(request.body)

        body["track_slug"] == solution.track.slug &&
          body["exercise_slug"] == solution.exercise.slug &&
          body["solution_files"] == {
            "log_line_parser.rb" => "class LogLineParser\nend",
            "subdir/new_file.rb" => "new file"
          } &&
          body["exercise_files"].keys.sort == [".meta/config.json", "log_line_parser.rb", "log_line_parser_test.rb"] &&
          body["exercise_files"]["log_line_parser_test.rb"].present?
      end.
      to_return(status: 200, body: { representation: "ast", mapping: {}, version: 1 }.to_json)

    Submission::Representation::Generate.(submission, submission.git_sha)

    assert submission.reload.representation_generated?
  end

  test "creates submission representation record" do
    submission = create :submission
    create(:submission_file, submission:)
    ast = "here(lives(an(ast)))"
    ast_digest = Submission::Representation.digest_ast(ast)

    stub_representer!(representation: ast)
    Submission::Representation::Generate.(submission, submission.git_sha)

    representation = submission.reload.submission_representation

    assert representation.tooling_job_id.start_with?("lambda-")
    assert_equal 200, representation.ops_status
    assert_equal ast_digest, representation.ast_digest
  end

  test "creates exercise representation" do
    freeze_time

    ast = "my ast"
    ast_digest = Submission::Representation.digest_ast(ast)
    submission = create :submission, tests_status: :passed
    create(:submission_file, submission:)
    mapping = { 'foo' => 'bar' }

    stub_representer!(representation: ast, mapping:)
    Submission::Representation::Generate.(submission, submission.git_sha)

    perform_enqueued_jobs

    assert_equal 1, Exercise::Representation.count
    representation = Exercise::Representation.first

    assert_equal submission.exercise, representation.exercise
    assert_equal ast, representation.ast
    assert_equal ast_digest, representation.ast_digest
    assert_equal mapping, representation.mapping
    assert_equal 1, representation.num_submissions
    assert_equal submission.submission_representation.created_at, representation.last_submitted_at
  end

  test "representer_version comes from the response" do
    submission = create :submission
    create(:submission_file, submission:)

    stub_representer!(version: 3)
    Submission::Representation::Generate.(submission, submission.git_sha)

    representation = Exercise::Representation.first
    assert_equal 3, representation.representer_version
  end

  test "test exercise representations are reused" do
    solution = create :concept_solution
    submission_1 = create(:submission, solution:)
    create :submission_file, submission: submission_1
    submission_2 = create(:submission, solution:)
    create :submission_file, submission: submission_2
    submission_3 = create(:submission, solution:)
    create :submission_file, submission: submission_3

    stub_representer!(representation: "ast 1")
    Submission::Representation::Generate.(submission_1, submission_1.git_sha)
    Submission::Representation::Generate.(submission_2, submission_2.git_sha)

    assert_equal 2, Submission::Representation.count
    assert_equal 1, Exercise::Representation.count

    stub_representer!(representation: "ast 2")
    Submission::Representation::Generate.(submission_3, submission_3.git_sha)
    assert_equal 3, Submission::Representation.count
    assert_equal 2, Exercise::Representation.count

    assert_equal submission_1.exercise_representation, submission_2.exercise_representation
    refute_equal submission_2.exercise_representation, submission_3.exercise_representation
  end

  test "handle bad request" do
    submission = create :submission
    create(:submission_file, submission:)

    Sentry.expects(:capture_exception).once

    stub_representer!(status: 400)
    Submission::Representation::Generate.(submission, submission.git_sha)

    assert submission.reload.representation_exceptioned?
    assert submission.submission_representation.ops_errored?
  end

  test "bad request for an update leaves the submission alone" do
    submission = create :submission, representation_status: :generated
    create(:submission_file, submission:)

    Sentry.expects(:capture_exception).once

    stub_representer!(status: 400)
    Submission::Representation::Generate.(submission, submission.git_sha, reason: :update)

    assert submission.reload.representation_generated?
    assert_nil submission.submission_representation
  end

  test "handle invalid ast" do
    exercise = create :concept_exercise
    submission = create(:submission, exercise:)
    create(:submission_file, submission:)

    stub_representer!(representation: "")
    Submission::Representation::Generate.(submission, submission.git_sha)

    assert submission.reload.representation_exceptioned?
  end

  test "handle generated" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise:,
      ast_digest: Submission::Representation.digest_ast(ast)

    submission = create(:submission, exercise:)
    create(:submission_file, submission:)

    stub_representer!(representation: ast)
    Submission::Representation::Generate.(submission, submission.git_sha)

    assert submission.reload.representation_generated?
  end

  test "handle exceptions during processing" do
    ast = "Some AST goes here..."
    exercise = create :concept_exercise
    create :exercise_representation,
      exercise:,
      ast_digest: Submission::Representation.digest_ast(ast),
      feedback_author: create(:user),
      feedback_markdown: "foobar"

    submission = create(:submission, exercise:)
    create(:submission_file, submission:)

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Submission::Representation::ProcessResults.any_instance.expects(:handle_generated!).raises
    end

    # We have a guard to reraise in dev/test here, so
    # stimulate production for this step
    Rails.env.expects(:production?).returns(true)

    stub_representer!(representation: ast)
    Submission::Representation::Generate.(submission, submission.git_sha)

    assert submission.reload.representation_exceptioned?
  end

  test "broadcast without iteration" do
    submission = create :submission
    create(:submission_file, submission:)

    SubmissionChannel.expects(:broadcast!).with(submission)

    stub_representer!
    Submission::Representation::Generate.(submission, submission.git_sha)
  end

  test "broadcast with iteration" do
    submission = create :submission
    create(:submission_file, submission:)
    iteration = create(:iteration, submission:)

    IterationChannel.expects(:broadcast!).with(iteration)
    SubmissionChannel.expects(:broadcast!).with(submission)

    stub_representer!
    Submission::Representation::Generate.(submission, submission.git_sha)
  end

  test "honours reason" do
    ast = "my ast"
    ast_digest = Submission::Representation.digest_ast(ast)
    submission = create :submission
    create(:submission_file, submission:)
    mapping = { 'foo' => 'bar' }

    Submission::Representation::Create.expects(:call).never
    Exercise::Representation::CreateOrUpdate.expects(:call).with(
      submission,
      ast, ast_digest, mapping.symbolize_keys,
      4, 1, submission.created_at, submission.git_sha
    )

    stub_representer!(representation: ast, mapping:, version: 4)
    Submission::Representation::Generate.(submission, submission.git_sha, reason: :update)
  end

  test "exercise_version is 1 by default" do
    # No version is set for hamming here
    exercise = create :practice_exercise, slug: "hamming", git_sha: "87448759c3f447c0a20db660b278a628e299e602"
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)
    create(:submission_file, submission:)

    stub_representer!
    Submission::Representation::Generate.(submission, submission.git_sha)

    representation = Exercise::Representation.last

    assert_equal 1, representation.exercise_version
  end

  test "exercise_version is set from the git_sha" do
    slug = "space-age"
    v1_sha = "8b874172f74acad07ca880c71814a85eb883e2d7"
    v2_sha = "9f9d8f5bdac4411d0497af0f393ae76f2ab33a97"
    exercise = create(:practice_exercise, slug:)
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)
    create(:submission_file, submission:)

    stub_representer!

    # First test with the v1_sha
    Submission::Representation::Generate.(submission, v1_sha)
    representation = Exercise::Representation.last
    assert_equal 1, representation.exercise_version

    # Then with the v2 sha
    Submission::Representation::Generate.(submission, v2_sha)
    representation = Exercise::Representation.last
    assert_equal 2, representation.exercise_version
  end

  test "cancels solutions that are too large without calling the representer" do
    submission = create :submission
    create :submission_file, submission:, filename: "one.rb", content: "a" * 150.kilobytes
    create :submission_file, submission:, filename: "two.rb", content: "a" * 51.kilobytes

    Submission::Representation::Generate.(submission, submission.git_sha)

    assert_not_requested :post, Exercism.config.representer_url
    assert submission.reload.representation_cancelled?
    assert_nil submission.submission_representation
  end

  %i[failed errored].each do |tests_status|
    test "cancels submissions with #{tests_status} tests without calling the representer" do
      submission = create :submission, tests_status:, representation_status: :queued
      create(:submission_file, submission:)

      Submission::Representation::Generate.(submission, submission.git_sha)

      assert_not_requested :post, Exercism.config.representer_url
      assert submission.reload.representation_cancelled?
      assert_nil submission.submission_representation
    end
  end

  test "skips reruns of submissions with failed tests" do
    submission = create :submission, tests_status: :failed, representation_status: :generated
    create(:submission_file, submission:)

    Submission::Representation::Generate.(submission, submission.git_sha, reason: :update)

    assert_not_requested :post, Exercism.config.representer_url
    assert submission.reload.representation_generated?
  end

  test "cancels solutions without valid files" do
    submission = create :submission

    Submission::Representation::Generate.(submission, submission.git_sha)

    assert_not_requested :post, Exercism.config.representer_url
    assert submission.reload.representation_cancelled?
  end

  test "requeues on bad gateway" do
    submission = create :submission
    create(:submission_file, submission:)

    stub_representer!(status: 502)

    Submission::Representation::Generate.expects(:defer).with do |sub, git_sha, **kwargs|
      sub == submission && git_sha == submission.git_sha && kwargs[:reason].nil? &&
        kwargs[:retries_count] == 1 && kwargs[:wait].between?(30, 90)
    end
    Submission::Representation::Generate.(submission, submission.git_sha)

    assert_nil submission.reload.submission_representation
  end

  test "requeues in the background on bad gateway" do
    submission = create :submission
    create(:submission_file, submission:)

    stub_representer!(status: 503)

    Submission::Representation::Generate::InBackground.expects(:defer).with do |sub, _git_sha, **kwargs|
      sub == submission && kwargs[:retries_count] == 1
    end
    Submission::Representation::Generate::InBackground.(submission, submission.git_sha)
  end

  test "requeues on timeout" do
    submission = create :submission
    create(:submission_file, submission:)

    stub_request(:post, Exercism.config.representer_url).to_timeout

    Submission::Representation::Generate.expects(:defer).with do |sub, _git_sha, **kwargs|
      sub == submission && kwargs[:retries_count] == 1
    end
    Submission::Representation::Generate.(submission, submission.git_sha)
  end

  test "marks as exceptioned and raises after max retries exhausted" do
    submission = create :submission
    create(:submission_file, submission:)

    stub_representer!(status: 504)

    assert_raises Submission::Representation::Generate::RepresenterTemporarilyUnavailable do
      Submission::Representation::Generate.(submission, submission.git_sha, retries_count: 3)
    end

    assert submission.reload.representation_exceptioned?
    assert submission.submission_representation.ops_errored?
  end

  test "runs reruns on the background queue" do
    assert_equal :solution_processing, Submission::Representation::Generate.active_job_queue
    assert_equal :background, Submission::Representation::Generate::InBackground.active_job_queue
  end
end
