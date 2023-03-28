module Badges
  class DiscourserBadge < Badge
    seed "Discourser",
      :common,
      'discourser',
      'Linked your Exercism account to the Forum'

    def award_to?(user) = has_discourse_account?(user)

    def send_email_on_acquisition? = true

    private
    def has_discourse_account?(user)
      Exercism.discourse_client.by_external_id(user.id)
      true
    rescue DiscourseApi::NotFoundError
      false
    end
  end
end
