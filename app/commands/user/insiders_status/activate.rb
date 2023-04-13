class User::InsidersStatus::Activate
  include Mandate

  initialize_with :user

  def call
    user.with_lock do
      return unless %i[eligible eligible_lifetime].include?(user.insiders_status)

      lifetime_insider = user.insiders_status == :eligible_lifetime
      insiders_status = lifetime_insider ? :active_lifetime : :active
      notification_type = lifetime_insider ? :joined_lifetime_insiders : :joined_insiders

      user.update(insiders_status:)
      user.update(flair: :insider) unless %i[founder staff original_insider].include?(user.flair)
      User::Notification::Create.(user, notification_type) if FeatureFlag::INSIDERS
    end
  end
end
