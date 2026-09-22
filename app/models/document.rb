class Document < ApplicationRecord
  extend Mandate::Memoize
  extend FriendlyId
  include HasTranslatedMetadata

  OPENSEARCH_INDEX = "#{Rails.env}-documents".freeze

  disable_sti!

  friendly_id :slug, use: [:history]

  belongs_to :track, optional: true

  scope :sorted, -> { order(:position) }

  after_save_commit do
    Document::SyncToSearchIndex.defer(self)
  end

  def title = translated_metadata(translation_metadata_unit_id(:title), super)
  def blurb = translated_metadata(translation_metadata_unit_id(:blurb), super)
  def nav_title = super.presence || title

  def translation_metadata_repo_name = track ? track.translation_metadata_repo_name : "docs"

  def subsections
    return [] if apex?

    slug.split('/').tap(&:pop)
  end

  def apex?
    slug == "APEX"
  end

  memoize
  def markdown
    repo = Git::Repository.new(repo_url: git_repo, branch_ref: ENV['GIT_DOCS_BRANCH'])
    repo.read_translated_text_blob(repo.head_commit, git_path)
  end

  memoize
  def content_html
    Markdown::Parse.(markdown, strip_h1: true, lower_heading_levels_by: 0, heading_ids: true)
  end

  private
  def translation_metadata_unit_id(field) = "#{track_id ? 'doc' : section}:#{slug}:#{field}"

  REPO_NAME = "exercism/docs".freeze
  REPO_URL = "https://github.com/#{REPO_NAME}".freeze
end
