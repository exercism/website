class Exercise::Approach::Introduction::Contributorship < ApplicationRecord
  belongs_to :exercise
  belongs_to :contributor,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :approach_introduction_contributorships
end
