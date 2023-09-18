class Partner::Advert < ApplicationRecord
  belongs_to :partner
  has_one_attached :light_logo
  has_one_attached :dark_logo

  enum status: { pending: 0, active: 1, out_of_budget: 2, retired: 3 }

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  def to_param
    uuid
  end
end
