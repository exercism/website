class Exercise::Approach < ApplicationRecord
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

  # TODO: (Optional): This was memoized but because git_sha can change
  # this can actually end up being incorrectly memoized. How do we
  # deal with this?
  def git = Git::Exercise::Approach.new(slug, exercise.slug, exercise.git_type, synced_to_git_sha, repo_url: exercise.track.repo_url)
end
