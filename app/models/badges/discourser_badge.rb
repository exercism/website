module Badges
  class DiscourserBadge < Badge
    seed "Discourser",
      :common,
      'discourser',
      "Joined Exercism's forum"

    def award_to?(user) = has_discourse_account?(user)

    def send_email_on_acquisition? = false

    private
    def has_discourse_account?(user)
      Exercism.discourse_client.by_external_id(user.id)
      true
    rescue DiscourseApi::NotFoundError
      false
    end
  end
end
