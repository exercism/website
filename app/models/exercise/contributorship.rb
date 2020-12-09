class Exercise::Contributorship < ApplicationRecord
  belongs_to :exercise
  belongs_to :contributor,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :contributorships
end
