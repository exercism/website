class Donations::Payment < ApplicationRecord
  belongs_to :user
  belongs_to :subscription, optional: true
end
