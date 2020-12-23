class ScratchpadPage < ApplicationRecord
  belongs_to :about, polymorphic: true
  belongs_to :author, # rubocop:disable Rails/InverseOf
    class_name: "User",
    foreign_key: "user_id"

  has_markdown_field :content
end
