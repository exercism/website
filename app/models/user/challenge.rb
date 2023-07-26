class User::Challenge < ApplicationRecord
  belongs_to :user

  CHALLENGE_12_IN_23 = "12in23".freeze
  CHALLENGES = [CHALLENGE_12_IN_23].freeze
end
