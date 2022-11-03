class User::Mailshot < ApplicationRecord
  include Emailable

  belongs_to :user

  # We currently always want this email to be sent, so there
  # is no communication preference key
  # TODO: Add a flag for whether the email is a marketing
  # email and use it to power this.
  def email_communication_preferences_key
    :receive_product_updates
  end
end
