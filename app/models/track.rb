class Track < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

  has_many :concepts, class_name: "Track::Concept", dependent: :destroy
  has_many :exercises, dependent: :destroy

  has_many :concept_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :practice_exercises # rubocop:disable Rails/HasManyOrHasOneDependent

  scope :active, -> { where(active: true) }

  delegate :test_regexp,
    :ignore_regexp,
    to: :git

  delegate :head_sha, to: :git, prefix: true

  def self.for!(param)
    return param if param.is_a?(Track)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(slug: param)
  end

  memoize
  def git
    # TODO: Slug can be removed from this
    # once we're out of the monorepo
    Git::Track.new(slug, repo_url: repo_url)
  end

  # TODO: Set this properly
  def icon_url
    "https://assets.exercism.io/tracks/ruby-hex-white.png"
  end
end
