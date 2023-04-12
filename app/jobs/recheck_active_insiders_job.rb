class RecheckActiveInsidersJob < ApplicationJob
  queue_as :default

  def perform
    User.where(insiders_status: :active).find_each do |user|
      Insiders::UpdateStatus.(user)
    end
  end
end
