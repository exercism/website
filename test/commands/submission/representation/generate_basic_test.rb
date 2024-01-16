require 'test_helper'

class Submission::Representation::GenerateBasicTest < ActiveSupport::TestCase
  test "creates submission representation record" do
    filename = "something.rb"
    code = "foo"
    digest = Submission::Representation.digest_ast("#{filename}\n#{code}")
    submission = create :submission
    create :submission_file, submission:, filename:, content: code

    uuid = SecureRandom.compact_uuid
    SecureRandom.expects(:compact_uuid).returns(uuid).at_least_once

    Submission::Representation::GenerateBasic.(submission)

    representation = submission.reload.submission_representation

    assert_equal submission, representation.submission
    assert_equal "basic-#{uuid}", representation.tooling_job_id
    assert_equal 200, representation.ops_status
    assert_equal digest, representation.ast_digest
  end

  test "creates exercise representation" do
    filename = "something.rb"
    code = "foo"
    normalised_code = "#{filename}\n#{code}"
    digest = Submission::Representation.digest_ast(normalised_code)
    submission = create :submission, tests_status: :passed
    create :submission_file, submission:, filename:, content: code

    Submission::Representation::GenerateBasic.(submission)

    perform_enqueued_jobs

    assert_equal 1, Exercise::Representation.count
    representation = Exercise::Representation.first

    assert_equal submission.exercise, representation.exercise
    assert_equal normalised_code, representation.ast
    assert_equal digest, representation.ast_digest
    assert_empty(representation.mapping)
    assert_equal 0, representation.representer_version
    assert_equal 1, representation.exercise_version
    assert_equal 1, representation.num_submissions
    assert_equal submission.created_at, representation.last_submitted_at
  end

  test "normalises ast correctly" do
    filename_1 = "start.rb"
    code_1 = "foo eeee"
    filename_2 = "end.rb"
    code_2 = "bar wwww \n aaaa"

    # Check things are normalised correctly
    # Check things are normalised correctly
    expected_ast = <<~AST
      start.rb
      fooeeee

      end.rb
      barwwwwaaaa
    AST
    digest = Submission::Representation.digest_ast(expected_ast.chomp)
    submission = create :submission
    create :submission_file, submission:, filename: filename_1, content: code_1
    create :submission_file, submission:, filename: filename_2, content: code_2

    uuid = SecureRandom.compact_uuid
    SecureRandom.expects(:compact_uuid).returns(uuid).at_least_once

    Submission::Representation::GenerateBasic.(submission)

    representation = submission.reload.submission_representation

    assert_equal submission, representation.submission
    assert_equal "basic-#{uuid}", representation.tooling_job_id
    assert_equal 200, representation.ops_status
    assert_equal digest, representation.ast_digest
  end

  test "test exercise representations are reused" do
    solution = create :concept_solution
    submission_1 = create(:submission, solution:)
    create :submission_file, submission: submission_1, content: "foobar"
    submission_2 = create(:submission, solution:)
    create :submission_file, submission: submission_2, content: "foobar"
    submission_3 = create(:submission, solution:)
    create :submission_file, submission: submission_3, content: "other"

    Submission::Representation::GenerateBasic.(submission_1)
    Submission::Representation::GenerateBasic.(submission_2)

    assert_equal 2, Submission::Representation.count
    assert_equal 1, Exercise::Representation.count

    Submission::Representation::GenerateBasic.(submission_3)
    assert_equal 3, Submission::Representation.count
    assert_equal 2, Exercise::Representation.count

    assert_equal submission_1.exercise_representation, submission_2.exercise_representation
    refute_equal submission_2.exercise_representation, submission_3.exercise_representation
  end

  test "handle generated" do
    submission = create :submission
    create(:submission_file, submission:)

    Submission::Representation::GenerateBasic.(submission)

    assert submission.reload.representation_generated?
  end

  test "errors without a file" do
    submission = create :submission

    Submission::Representation::GenerateBasic.(submission)

    assert submission.reload.representation_exceptioned?
  end

  test "handle exceptions during processing" do
    submission = create :submission
    create(:submission_file, submission:)

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Submission::Representation::ProcessResults.any_instance.expects(:handle_generated!).raises
    end

    # We have a guard to reraise in dev/test here, so
    # stimulate production for this step
    Rails.env.expects(:production?).returns(true)

    Submission::Representation::GenerateBasic.(submission)

    assert submission.reload.representation_exceptioned?
  end

  test "broadcast without iteration" do
    submission = create :submission
    create(:submission_file, submission:)

    SubmissionChannel.expects(:broadcast!).with(submission)

    Submission::Representation::GenerateBasic.(submission)
  end

  test "broadcast with iteration" do
    submission = create :submission
    create(:submission_file, submission:)
    iteration = create(:iteration, submission:)

    IterationChannel.expects(:broadcast!).with(iteration)
    SubmissionChannel.expects(:broadcast!).with(submission)

    Submission::Representation::GenerateBasic.(submission)
  end

  test "exercise_version reads from git" do
    # No version is set for hamming here
    exercise = create :practice_exercise, slug: "hamming", git_sha: "87448759c3f447c0a20db660b278a628e299e602"
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)
    create(:submission_file, submission:)
    Submission::Representation::GenerateBasic.(submission)

    representation = Exercise::Representation.last

    assert_equal 1, representation.exercise_version
  end
end
