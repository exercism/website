class User::BootcampData < ApplicationRecord
  belongs_to :user

  def enrolled? = enrolled_at.present?
end
