class Admin::PremiumController < Admin::BaseController
  def index
    @num_subscribers = Payments::Payment.premium.joins(user: :data).
      where.not("JSON_CONTAINS(user_data.roles, ?, '$')", %("admin")).
      select(:user_id).distinct.count
  end
end
