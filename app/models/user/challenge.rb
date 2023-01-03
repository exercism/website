class User::Challenge < ApplicationRecord
  belongs_to :user

  CHALLENGES = ["12in23"].freeze
end
