class Exercise::Contributorship < ApplicationRecord
  belongs_to :exercise
  belongs_to :contributor, # rubocop:disable Rails/InverseOf
    class_name: "User",
    foreign_key: :user_id
end
