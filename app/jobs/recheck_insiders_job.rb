class RecheckInsidersJob < ApplicationJob
  queue_as :default

  def perform
    User.with_data.where(data: { insiders_status: %i[eligible active] }).find_each do |user|
      User::InsidersStatus::Update.(user)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end
end
