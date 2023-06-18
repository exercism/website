class Partner < ApplicationRecord
  has_one_attached :logo

  has_markdown_field :description

  has_many :adverts, dependent: :destroy
  has_many :perks, dependent: :destroy
end
