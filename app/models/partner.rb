class Partner < ApplicationRecord
  has_one_attached :logo

  has_markdown_field :description
end
