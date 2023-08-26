# Send with:
# slug = "launch_trophies"
# email_communication_preferences_key = :receive_product_updates
# mailshot = Mailshot.find_create_or_find_by!(slug: slug) do |ms|
#   ms.email_communication_preferences_key= :receive_product_updates
#   ms.subject= ""
#   ms.button_url= ""
#   ms.button_text= ""
#   ms.text_content= ""
#   ms.content_markdown= ""
#   ms.content_html= ""
# end
#
# UserTrack::AcquiredTrophy.where(revealed: false).includes(:user).find_each do |trophy|
#   User::Mailshot::SendWithCustomMailer.(trophy.user, mailshot)
# end
class User::Mailshot::SendWithCustomMailer
  include Mandate

  initialize_with :user, :mailshot

  # This returns a boolean based on whether it succeeds or not
  # It returns the value of User::SendEmail if no exception occurs
  def call
    user_mailshot = User::Mailshot.create_or_find_by!(mailshot:, user:)
    User::SendEmail.(user_mailshot) do
      MailshotsMailer.with(
        user:,
        mailshot:
      ).send(mailshot.slug).deliver_later
    end
  end
end
