class Exercise::Article < ApplicationRecord
  extend Mandate::Memoize
  extend FriendlyId

  belongs_to :exercise

  friendly_id :slug, use: [:history]

  has_many :authorships,
    class_name: "Exercise::Article::Authorship",
    foreign_key: :exercise_article_id,
    inverse_of: :article,
    dependent: :destroy
  has_many :authors, through: :authorships, source: :author

  has_many :contributorships,
    class_name: "Exercise::Article::Contributorship",
    foreign_key: :exercise_article_id,
    inverse_of: :article,
    dependent: :destroy
  has_many :contributors, through: :contributorships, source: :contributor

  has_one :track, through: :exercise

  scope :random, -> { order('RAND()') }
  default_scope -> { order(:position) }

  delegate :content, :snippet, to: :git

  memoize
  def git = Git::Exercise::Article.new(slug, exercise.slug, exercise.git_type, synced_to_git_sha, repo_url: track.repo_url)

  memoize
  def content_html = Markdown::Parse.(content)

  memoize
  def snippet_html = Markdown::Parse.(snippet, heading_ids: false)
end
