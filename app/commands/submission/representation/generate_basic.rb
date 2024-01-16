class Submission::Representation::GenerateBasic
  include Mandate

  queue_as :solution_processing

  initialize_with :submission

  def call
    Submission::Representation::ProcessResults.(
      submission, submission.git_sha,
      nil,
      "basic-#{SecureRandom.compact_uuid}", 200,
      normalised_code, normalised_code_digest, {},
      0, exercise_version
    )
  end

  memoize
  def normalised_code_digest
    Submission::Representation.digest_ast(normalised_code)
  end

  memoize
  def normalised_code
    files.map do |file|
      [file.filename, file.content.gsub(/\s/, "")].join("\n")
    end.join("\n\n")
  end

  memoize
  def exercise_version
    git_exercise = Git::Exercise.for_solution(solution, git_sha:)
    git_exercise.representer_version
  end

  memoize
  def files
    valid_paths = submission.valid_filepaths(submission.exercise_repo)
    submission.files.select { |file| valid_paths.include?(file.filename) }
  end

  delegate :git_sha, :solution, to: :submission
end
