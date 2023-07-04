class Partner < ApplicationRecord
  has_one_attached :light_logo
  has_one_attached :dark_logo

  has_markdown_field :support
  has_markdown_field :description

  has_many :adverts, dependent: :destroy
  has_many :perks, dependent: :destroy

  def website_domain
    PublicSuffix.domain(URI.parse(website_url).host)
  rescue StandardError
    ""
  end

  def to_param
    slug
  end
end
