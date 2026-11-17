# Sends a donor to Stripe's hosted page, where they can update the card used
# for their recurring donation.
class Settings::StripeBillingPortalController < ApplicationController
  def show
    url = Payments::Stripe::BillingPortal::CreateSession.(current_user, donations_settings_url)

    redirect_to url || donations_settings_path, allow_other_host: true
  end
end
