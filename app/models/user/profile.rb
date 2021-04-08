class User::Profile < ApplicationRecord
  belongs_to :user

  delegate :to_param, to: :user
end
