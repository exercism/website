class Solution < ApplicationRecord
  belongs_to :user
  belongs_to :exercise
  has_one :track, through: :exercise
  has_many :iterations

  has_many :mentor_requests, class_name: "Solution::MentorRequest"
  has_many :mentor_discussions, class_name: "Solution::MentorDiscussion"

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

  # TODO - Use an actual serializer
  def serialized_iterations
    iterations.map do |i|
      {
        id: i.id,
        testsStatus: i.tests_status
      }
    end
  end
end
