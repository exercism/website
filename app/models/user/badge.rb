class User::Badge < ApplicationRecord
  belongs_to :user
  belongs_to :badge, class_name: "::Badge"
end
