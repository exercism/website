class Admin::InsidersController < Admin::BaseController
  def index
    @num_subscribers = Payments::Subscription.active.joins(user: :data).
      where("user_data.roles IS NULL OR NOT JSON_CONTAINS(user_data.roles, ?, '$')", %("admin")).
      select(:user_id).distinct.count

    @total_recurring_amount_in_dollars = Payments::Subscription.active.sum(:amount_in_cents) / 100.00
  end
end
