class Partner::Perk < ApplicationRecord
  belongs_to :partner
  has_one_attached :light_logo
  has_one_attached :dark_logo

  has_markdown_field :general_offer
  has_markdown_field :premium_offer

  enum audience: { general: 0, premium: 1 }
  enum status: { pending: 0, active: 1, out_of_budget: 2, retired: 3 }

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  def to_param
    uuid
  end

  def url_for_user(user)
    user&.premium? && premium_button_text.present? ?
    premium_url : general_url
  end

  def offer_html_for_user(user)
    user&.premium? && premium_offer_markdown.present? ?
    premium_offer_html : general_offer_html
  end

  def button_text_for_user(user)
    user&.premium? && premium_button_text.present? ?
    premium_button_text : general_button_text
  end
end
