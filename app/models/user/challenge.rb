class User::Challenge < ApplicationRecord
  belongs_to :user

  CHALLENGE_12_IN_23 = "12in23".freeze
  CHALLENGE_48_IN_24 = "48in24".freeze
  CHALLENGES = [
    CHALLENGE_12_IN_23,
    CHALLENGE_48_IN_24
  ].freeze
end
