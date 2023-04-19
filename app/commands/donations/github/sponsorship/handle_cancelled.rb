# This responds to a Github sponsorship webhook event with
# the action being 'cancelled'
class Donations::Github::Sponsorship::HandleCancelled
  include Mandate

  initialize_with :user, :node_id, :privacy_level, :is_one_time, :monthly_price_in_cents

  def call
    # TODO
  end
end
