class Solution::MentorDiscussion < ApplicationRecord
  belongs_to :solution
  belongs_to :mentor, class_name: "User"
  belongs_to :request, class_name: "Solution::MentorRequest"

  has_many :posts, class_name: "Solution::MentorDiscussionPost",
                   foreign_key: "discussion_id",
                   dependent: :destroy,
                   inverse_of: :discussion

  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where(completed_at: nil) }

  before_validation do
    self.solution = request.solution unless self.solution
  end
end
