class AwardReputationTokenJob < ApplicationJob
  queue_as :reputation

  def perform(user, type, params = {})
    User::ReputationToken::Create.(user, type, params)
  end
end
