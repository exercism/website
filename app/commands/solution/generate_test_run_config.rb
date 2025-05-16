class Solution::GenerateTestRunConfig
  include Mandate

  initialize_with :solution

  def call
    {
      files: exercise_repo.tooling_files
    }
  end

  private
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
