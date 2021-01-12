class Iteration < ApplicationRecord
  belongs_to :solution
  belongs_to :submission

  has_many :mentor_discussion_posts, class_name: "Solution::MentorDiscussionPost", dependent: :destroy

  has_one :exercise, through: :solution
  has_one :track, through: :exercise

  delegate :tests_status, to: :submission
  delegate :discussion, to: :solution

  before_create do
    self.uuid = SecureRandom.compact_uuid unless self.uuid
  end

  def viewable_by?(user)
    solution.mentors.include?(user) || solution.user == user
  end
end
