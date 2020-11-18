class Solution::MentorDiscussionPost < ApplicationRecord
  belongs_to :discussion,
    class_name: "Solution::MentorDiscussion"

  belongs_to :author, # rubocop:disable Rails/InverseOf
    class_name: "User",
    foreign_key: "user_id"

  belongs_to :iteration

  has_one :solution, through: :iteration

  validates :content_markdown, presence: true

  has_markdown_field :content
end
