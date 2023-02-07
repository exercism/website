class User::Mailshot < ApplicationRecord
  include Emailable

  PREFERENCE_KEYS = {
    email_about_events: %w[
      upcoming_jose_valim
    ],
    receive_product_updates: %w[
      challenge_12in23_launch
    ]
  }.freeze

  belongs_to :user

  # We currently always want this email to be sent, so there
  # is no communication preference key
  # TODO: Add a flag for whether the email is a marketing
  # email and use it to power this.
  def email_communication_preferences_key
    PREFERENCE_KEYS.each do |key, mailers|
      return key if mailers.include?(mailshot_id)
    end

    raise "Communication preference key not sent in mailshot"
  end
end
