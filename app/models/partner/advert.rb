class Partner::Advert < ApplicationRecord
  belongs_to :partner
  has_one_attached :light_logo
  has_one_attached :dark_logo

  enum status: { pending: 0, active: 1, out_of_budget: 2, retired: 3 }

  serialize :track_slugs, JSON

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  before_save do
    self.html = Markdown::Parse.(markdown)
  end

  def to_param
    uuid
  end
end
