class ProblemSpecifications::Exercise
  include Mandate

  attr_reader :slug

  delegate :title, :blurb, :source, :source_url, :deprecated?, to: :git

  def initialize(slug, repo: nil)
    @slug = slug
    @repo = repo
  end

  def url = "https://github.com/exercism/problem-specifications/tree/main/exercises/#{slug}"
  def icon_url = "#{Exercism.config.website_icons_host}/exercises/#{slug}.svg"

  private
  attr_reader :repo

  memoize
  def git = Git::ProblemSpecifications::Exercise.new(slug, repo:)
end
