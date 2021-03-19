class Document < ApplicationRecord
  extend Mandate::Memoize
  extend FriendlyId
  disable_sti!

  friendly_id :slug, use: [:history]

  belongs_to :track, optional: true

  def nav_title
    super.presence || title
  end

  def subsections
    return [] if apex?

    slug.split('/').tap(&:pop)
  end

  def apex?
    slug == "APEX"
  end

  def content_html
    repo = Git::Repository.new(repo_url: git_repo)
    markdown = repo.read_text_blob(repo.head_commit, git_path)
    Markdown::Parse.(markdown, strip_h1: true, lower_heading_levels_by: 0)
  end
end
