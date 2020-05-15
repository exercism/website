class Solution::DiscussionPost < ApplicationRecord
  belongs_to :discussion, polymorphic: true
  belongs_to :iteration

  validates :content_markdown, presence: true
end
