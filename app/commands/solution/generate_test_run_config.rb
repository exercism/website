class Solution::GenerateTestRunConfig
  include Mandate

  initialize_with :solution

  def call
    return nil unless track.slug == "javascript"

    {
      files: exercise_repo.tooling_files
    }
  end

  private
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
