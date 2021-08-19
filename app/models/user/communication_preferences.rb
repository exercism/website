class User::CommunicationPreferences < ApplicationRecord
  belongs_to :user

  before_create do
    self.token = SecureRandom.compact_uuid
  end
end
