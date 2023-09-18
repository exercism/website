class Payments::Coinbase::HandleResolvedCharge
  include Mandate

  initialize_with :event

  def call
    return unless user

    AwardBadgeJob.perform_later(user, :supporter)
  end

  private
  attr_reader :id

  memoize
  def user
    custom_data = event.metadata['custom']
    return unless custom_data

    user_id = custom_data.gsub(/^user-/, '').to_i

    user_id.zero? ? nil : User.find(user_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
