class Bootcamp::Drawing < ApplicationRecord
  belongs_to :user

  before_create do
    self.uuid = SecureRandom.uuid unless uuid.present?
    self.code = "" unless code.present?
  end

  def to_param = uuid
end
