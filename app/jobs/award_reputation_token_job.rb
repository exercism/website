class AwardReputationTokenJob < ApplicationJob
  queue_as :low_priority

  def perform(user, type, params = {})
    User::ReputationToken::Create.(user, type, params)
  end
end
