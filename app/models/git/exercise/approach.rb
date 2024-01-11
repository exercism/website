class Git::Exercise::Approach
  extend Mandate::Memoize
  extend Mandate::InitializerInjector
  extend Git::HasGitFilepath

  delegate :commit, :repo, :head_sha, :approaches_snippet_extension, to: :git_track

  git_filepath :content, file: "content.md"
  git_filepath :snippet, file: ->(m) { "snippet.#{m.approaches_snippet_extension}" }

  initialize_with :approach_slug, :exercise_slug, :exercise_type, :git_track, git_sha: "HEAD"

  private
  attr_reader :git_track, :approach_slug, :exercise_slug, :exercise_type, :git_sha

  def absolute_filepath(filepath) = "#{dir}/#{filepath}"

  memoize
  def dir = "exercises/#{exercise_type}/#{exercise_slug}/.approaches/#{approach_slug}"
end
