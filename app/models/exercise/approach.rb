class Exercise::Approach < ApplicationRecord
  extend Mandate::Memoize
  extend FriendlyId

  belongs_to :exercise

  friendly_id :slug, use: [:history]

  has_many :authorships,
    class_name: "Exercise::Approach::Authorship",
    foreign_key: :exercise_approach_id,
    inverse_of: :approach,
    dependent: :destroy
  has_many :authors, through: :authorships, source: :author

  has_many :contributorships,
    class_name: "Exercise::Approach::Contributorship",
    foreign_key: :exercise_approach_id,
    inverse_of: :approach,
    dependent: :destroy
  has_many :contributors, through: :contributorships, source: :contributor

  has_many :submissions,
    inverse_of: :approach,
    dependent: :destroy

  has_one :track, through: :exercise

  scope :random, -> { order('RAND()') }
  default_scope { order(:position) }

  delegate :content, :snippet, to: :git

  memoize
  def git = Git::Exercise::Approach.new(slug, exercise.slug, exercise.git_type, track.git, git_sha: synced_to_git_sha)

  memoize
  def content_html = Markdown::Parse.(content)

  def matches_tags?(check_tags)
    return false if check_tags.blank?
    return false if tags.blank?

    all_tags = tags["all"].to_a
    return false if all_tags.present? && (all_tags - check_tags).present?

    any_tags = tags["any"].to_a
    return false if any_tags.present? && (any_tags & check_tags).empty?

    not_tags = tags["not"].to_a
    return false if not_tags.present? && (not_tags & check_tags).present?

    true
  end
end
