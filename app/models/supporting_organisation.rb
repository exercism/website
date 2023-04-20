class SupportingOrganisation < ApplicationRecord
  has_one_attached :logo

  has_markdown_field :description

  scope :featured, -> { where(featured: true) }
end
