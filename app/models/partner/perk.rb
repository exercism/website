class Partner::Perk < ApplicationRecord
  belongs_to :partner
  has_one_attached :light_logo
  has_one_attached :dark_logo

  has_markdown_field :general_offer_summary
  has_markdown_field :insiders_offer_summary

  enum audience: { general: 0, insider: 1 }
  enum status: { pending: 0, active: 1, out_of_budget: 2, retired: 3 }

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  def to_param
    uuid
  end

  def url_for_user(user)
    user&.insider? && insiders_button_text.present? ?
    insiders_url : general_url
  end

  def offer_summary_html_for_user(user)
    user&.insider? && insiders_offer_summary_markdown.present? ?
    insiders_offer_summary_html : general_offer_summary_html
  end

  def button_text_for_user(user)
    user&.insider? && insiders_button_text.present? ?
    insiders_button_text : general_button_text
  end

  def offer_details_for_user(user)
    user&.insider? && insiders_offer_details.present? ?
    insiders_offer_details : general_offer_details
  end

  def voucher_code?
    general_voucher_code.present?
  end

  def voucher_code_for_user(user)
    user&.insider? && insiders_voucher_code.present? ?
    insiders_voucher_code : general_voucher_code
  end
end
