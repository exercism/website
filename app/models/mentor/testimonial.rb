class Mentor::Testimonial < ApplicationRecord
  belongs_to :mentor, class_name: "User"
  belongs_to :student, class_name: "User"
  belongs_to :discussion, class_name: "Solution::MentorDiscussion"
  has_one :solution, through: :discussion
  has_one :exercise, through: :solution
  has_one :track, through: :exercise
end
