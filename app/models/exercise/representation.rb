class Exercise::Representation < ApplicationRecord
  belongs_to :exercise
  has_markdown_field :feedback
end
