class Exercise::Authorship < ApplicationRecord
  belongs_to :exercise
  belongs_to :author, # rubocop:disable Rails/InverseOf
    class_name: "User",
    foreign_key: :user_id
end
