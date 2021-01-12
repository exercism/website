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

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  def by_student?
    discussion.student == author
  end

  def to_param
    uuid
  end

  delegate :idx, to: :iteration, prefix: true
end
