class Submission::DiscussionPost < ApplicationRecord
  belongs_to :source, polymorphic: true, optional: true
  belongs_to :submission
  has_one :solution, through: :submission

  belongs_to :user

  validates :content_markdown, presence: true

  has_markdown_field :content
end
