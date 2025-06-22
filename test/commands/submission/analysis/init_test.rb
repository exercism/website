require 'test_helper'

class Submission::Analysis::InitTest < ActiveSupport::TestCase
  test "calls to publish_message" do
    solution = create :concept_solution
    exercise_repo = Git::Exercise.for_solution(solution)
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "log_line_parser.rb" # Override old file
    create :submission_file, submission:, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission:, filename: "log_line_parser_test.rb" # Don't override tests
    create :submission_file, submission:, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission:, filename: ".meta/config.json" # Don't allow meta

    SecureRandom.expects(:uuid).returns("foo-bar123-asd")
    job_id = "foobar123asd"
    efs_dir = "#{Exercism.config.efs_tooling_jobs_mount_point}/#{Time.current.utc.strftime('%Y/%m/%d')}/#{job_id}"

    Exercism::ToolingJob.expects(:create!).with(
      job_id,
      :analyzer,
      submission.uuid,
      efs_dir,
      solution.track.slug,
      solution.exercise.slug,
      run_in_background: false,
      source: {
        submission_efs_root: efs_dir,
        submission_filepaths: ["log_line_parser.rb", "subdir/new_file.rb"],
        exercise_git_repo: "ruby",
        exercise_git_sha: solution.git_sha,
        exercise_git_dir: exercise_repo.dir,
        exercise_filepaths: [".meta/config.json", ".meta/design.md", ".meta/exemplar.rb", "log_line_parser_test.rb"]
      },
      context: {}
    )
    Submission::Analysis::Init.(submission)
    assert_equal 'queued', submission.analysis_status
  end

  test "calls to publish_message for exercise with editor files" do
    exercise = create :practice_exercise, slug: 'isogram'
    solution = create(:practice_solution, exercise:)
    exercise_repo = Git::Exercise.for_solution(solution)
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "isogram.rb" # Override old file
    create :submission_file, submission:, filename: "subdir/new_file.rb" # Add new file
    create :submission_file, submission:, filename: "isogram_test.rb" # Don't override tests
    create :submission_file, submission:, filename: "special$chars.rb" # Don't allow special chars
    create :submission_file, submission:, filename: ".meta/config.json" # Don't allow meta

    SecureRandom.expects(:uuid).returns("foo-bar123-asd")
    job_id = "foobar123asd"
    efs_dir = "#{Exercism.config.efs_tooling_jobs_mount_point}/#{Time.current.utc.strftime('%Y/%m/%d')}/#{job_id}"

    Exercism::ToolingJob.expects(:create!).with(
      job_id,
      :analyzer,
      submission.uuid,
      efs_dir,
      solution.track.slug,
      solution.exercise.slug,
      run_in_background: false,
      source: {
        submission_efs_root: efs_dir,
        submission_filepaths: ["isogram.rb", "subdir/new_file.rb"],
        exercise_git_repo: "ruby",
        exercise_git_sha: solution.git_sha,
        exercise_git_dir: exercise_repo.dir,
        exercise_filepaths: [".meta/config.json", ".meta/example.rb", "helper.rb", "isogram_test.rb"]
      },
      context: {}
    )
    Submission::Analysis::Init.(submission)
    assert_equal 'queued', submission.analysis_status
  end
end
