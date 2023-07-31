class SendUserMailshotJob < ApplicationJob
  queue_as :dribble

  def perform(user, mailshot_id)
    User::Mailshot::Send.(user, mailshot_id)
  end
end
