class User::Mailshot < ApplicationRecord
  belongs_to :mailshot, class_name: "::Mailshot"

  delegate :email_communication_preferences_key, to: :mailshot

  include Emailable

  belongs_to :user
end
