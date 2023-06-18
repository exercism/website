class Partner::Advert < ApplicationRecord
  belongs_to :partner
  has_one_attached :logo

  enum status: { pending: 0, active: 1, out_of_budget: 2, retired: 3 }
end
