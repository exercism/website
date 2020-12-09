class Exercise::Authorship < ApplicationRecord
  belongs_to :exercise
  belongs_to :author,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :authorships
end
