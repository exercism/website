# Send with:
# users = User.where('reputation > 2').count
# users = User.where('reputation > 2').count
# users.each do |user|
#   User::Mailshot::Send.(user, :functional_february)
# end
class User::Mailshot::Send
  include Mandate

  initialize_with :user, :mailshot_id

  # This returns a boolean based on whether it succeeds or not
  # It returns the value of User::SendEmail if no exception occurs
  def call
    mailshot = User::Mailshot.create!(mailshot_id:, user_id: user.id)
    User::SendEmail.(mailshot) do
      MailshotsMailer.with(user:).send(mailshot_id).deliver_later
    end
  rescue ActiveRecord::RecordNotUnique
    false
  end
end
