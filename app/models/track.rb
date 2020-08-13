class Track < ApplicationRecord
  has_many :concepts, class_name: "Track::Concept", dependent: :destroy
  has_many :exercises, dependent: :destroy
  # has_many :concept_exercises
  # has_many :practice_exercises

  delegate :head_sha, to: :repo, prefix: "git"

  def self.for!(param)
    return param if param.is_a?(Track)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(slug: param)
  end

  # TODO: Memoize
  def repo
    # TODO: Slug can be removed from this
    # once we're out of the monorepo
    Git::Track.new(repo_url, slug)
  end
end
