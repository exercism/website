class Iteration::DiscussionPost < ApplicationRecord
  belongs_to :source, polymorphic: true, optional: true
  belongs_to :iteration
  belongs_to :user

  validates :content_markdown, presence: true

  has_markdown_field :content
end
