class RecheckPremiumJob < ApplicationJob
  queue_as :default

  def perform
    User.with_data.where('user_data.premium_until BETWEEN ? AND ?', Time.current - 2.days, Time.current).find_each do |user|
      User::Premium::Expire.(user)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end
end
