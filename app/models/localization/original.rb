class Localization::Original < ApplicationRecord
  has_many :translations, dependent: :destroy, foreign_key: :key, primary_key: :key, inverse_of: :original

  before_create do
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def to_param = uuid
end
