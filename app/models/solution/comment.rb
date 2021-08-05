class Solution::Comment < ApplicationRecord
  belongs_to :solution
  belongs_to :author, class_name: "User"

  validates :content_markdown, presence: true
  has_markdown_field :content, strip_h1: false, lower_heading_levels_by: 2
end
