class Exercise::Approach::Introduction::Authorship < ApplicationRecord
  belongs_to :exercise
  belongs_to :author,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :approach_introduction_authorships
end
