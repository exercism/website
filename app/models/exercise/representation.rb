class Exercise::Representation < ApplicationRecord

  enum action: [:pending, :approve, :disapprove]

  belongs_to :exercise
  belongs_to :feedback_author, optional: true, class_name: "User"
  belongs_to :feedback_editor, optional: true, class_name: "User"

  has_markdown_field :feedback
end
