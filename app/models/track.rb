class Track < ApplicationRecord
  extend FriendlyId

  friendly_id :slug, use: [:history]

  has_many :concepts, class_name: "Track::Concept", dependent: :destroy
  has_many :exercises, dependent: :destroy

  has_many :concept_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :practice_exercises # rubocop:disable Rails/HasManyOrHasOneDependent

  scope :active, -> { where(active: true) }

  def self.for!(param)
    return param if param.is_a?(Track)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(slug: param)
  end

  def test_regexp
    Regexp.new(test_pattern.presence || "[tT]est")
  end

  def ignore_regexp
    Regexp.new(ignore_pattern.presence || "[iI]gnore")
  end

  # TODO: Memoize
  def repo
    # TODO: Slug can be removed from this
    # once we're out of the monorepo
    Git::Track.new(repo_url, slug)
  end

  # TODO: Set this properly
  def icon_url
    "https://assets.exercism.io/tracks/ruby-hex-white.png"
  end
end
