class Solution::Comment < ApplicationRecord
  belongs_to :solution, counter_cache: :num_comments
  belongs_to :author, class_name: "User", foreign_key: :user_id, inverse_of: :solution_comments

  validates :content_markdown, presence: true
  has_markdown_field :content, strip_h1: false, lower_heading_levels_by: 2

  before_create do
    self.uuid = SecureRandom.uuid
  end

  def to_param = uuid
end
