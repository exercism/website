# Send with:
# users = User.where(id: 1530)
# users.each do |user|
#   User::Mailshot::Send.(user, :community_launch)
# end
class User::Mailshot::Send
  include Mandate

  initialize_with :user, :mailshot_id

  def call
    mailshot = User::Mailshot.create!(mailshot_id:, user_id: user.id)
    User::SendEmail.(mailshot) do
      MailshotsMailer.with(user:).send(mailshot_id).deliver_later
    end
  rescue ActiveRecord::RecordNotUnique
    # We're ok with silently catching this to avoid duplicates
  end
end
