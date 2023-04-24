class Submission::AIHelpRecord < ApplicationRecord
  belongs_to :submission

  validates :advice_markdown, presence: true

  has_markdown_field :advice, strip_h1: false
end
