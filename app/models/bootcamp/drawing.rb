class Bootcamp::Drawing < ApplicationRecord
  belongs_to :user

  before_create do
    self.uuid = SecureRandom.compact_uuid unless uuid.present?
    self.code = "" unless code.present?
    self.title = "Drawing #{user.bootcamp_drawings.count + 1}" unless title.present?
  end

  def to_param = uuid
end
