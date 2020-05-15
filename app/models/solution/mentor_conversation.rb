class Solution::MentorConversation < ApplicationRecord
  belongs_to :solution
  belongs_to :mentor, class_name: "User"
  belongs_to :request, class_name: "Solution::MentorRequest"

  before_validation do
    self.solution = request.solution
  end
end
