class Admin::PremiumController < Admin::BaseController
  def index
    @num_subscribers = Payments::Payment.premium.joins(user: :data).
      where("user_data.roles IS NULL OR NOT JSON_CONTAINS(user_data.roles, ?, '$')", %("admin")).
      select(:user_id).distinct.count
  end
end
