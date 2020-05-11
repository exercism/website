class Solution < ApplicationRecord
  belongs_to :user
  belongs_to :exercise
  has_one :track, through: :exercise
  has_many :iterations

  before_create do
    # Search engines derive meaning by using hyphens
    # as word-boundaries in URLs. Since we use the
    # solution UUID for URLs, we're removing the hyphen
    # to remove any spurious, accidental, and arbitrary
    # meaning.
    self.uuid = SecureRandom.compact_uuid unless self.uuid
    self.git_slug = exercise.slug
    self.git_sha = track.git_head_sha
  end
end
