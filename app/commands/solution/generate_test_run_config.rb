class Solution::GenerateTestRunConfig
  include Mandate

  initialize_with :solution, experimental: false

  def call
    return nil unless experimental || track.runs_tests_in_browser?

    {
      files: exercise_repo.tooling_files
    }
  end

  private
  # The browser runners need the exercise's own files - the test file, its
  # helpers, and .meta/config.json, which run.sh reads to find the test file -
  # not just what the student edits. They are only sent where they will be used:
  # for everyone else this is several more files in an already large payload.
  delegate :track, to: :solution

  memoize
  def exercise_repo
    Git::Exercise.new(
      solution.git_slug,
      solution.git_type,
      solution.git_sha,
      repo_url: solution.track.repo_url
    )
  end
end
