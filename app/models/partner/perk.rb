class Partner::Perk < ApplicationRecord
  belongs_to :partner
  has_one_attached :logo

  has_markdown_field :offer

  enum audience: { general: 0, premium: 1 }
  enum status: { pending: 0, active: 1, out_of_budget: 2, retired: 3 }
end
