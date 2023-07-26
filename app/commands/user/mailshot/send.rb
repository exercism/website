# Send with:
# users = User.where('reputation > 2').count
# users = User.where('reputation > 2').count
# users.each do |user|
#   User::Mailshot::Send.(user, :functional_february)
# end
class User::Mailshot::Send
  include Mandate

  initialize_with :user, :mailshot

  # This returns a boolean based on whether it succeeds or not
  # It returns the value of User::SendEmail if no exception occurs
  def call
    user_mailshot = User::Mailshot.create!(mailshot:, user:)
    User::SendEmail.(user_mailshot) do
      MailshotsMailer.with(
        user:,
        mailshot:
      ).send(:mailshot).deliver_later
    end
  rescue ActiveRecord::RecordNotUnique
    false
  end
end
