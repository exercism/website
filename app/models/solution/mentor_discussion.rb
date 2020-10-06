class Solution::MentorDiscussion < ApplicationRecord
  belongs_to :solution
  belongs_to :mentor, class_name: "User"
  belongs_to :request, class_name: "Solution::MentorRequest"

  has_many :posts, class_name: "Submission::DiscussionPost", as: :source, dependent: :destroy

  before_validation do
    self.solution = request.solution
  end
end
