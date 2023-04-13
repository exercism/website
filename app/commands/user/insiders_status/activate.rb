class User::InsidersStatus::Activate
  include Mandate

  initialize_with :user

  def call
    return unless %i[eligible eligible_lifetime].include?(user.insiders_status)

    if user.insiders_status == :eligible
      user.with_lock { user.update(insiders_status: :active) }
      User::Notification::Create.(user, :joined_insiders) if FeatureFlag::INSIDERS
    else
      user.with_lock { user.update(insiders_status: :active_lifetime) }
      User::Notification::Create.(user, :joined_lifetime_insiders) if FeatureFlag::INSIDERS
    end

    AwardBadgeJob.perform_later(user, :insider) if FeatureFlag::INSIDERS
  end
end
