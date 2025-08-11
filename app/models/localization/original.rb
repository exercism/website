class Localization::Original < ApplicationRecord
  has_many :translations, dependent: :destroy

  before_create do
    self.uuid = SecureRandom.uuid if uuid.blank?
    self.sample_interpolations = []
  end

  def to_param = uuid
end
