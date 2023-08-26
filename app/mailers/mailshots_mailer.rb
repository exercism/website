class MailshotsMailer < ApplicationMailer
  layout false

  def mailshot
    @user = params[:user]
    @mailshot = params[:mailshot]

    bulk_mail(@user, @mailshot.subject)
  end

  def launch_trophies
    @user = params[:user]
    acquired_trophies = @user.acquired_trophies
    @num_trophies = acquired_trophies.count
    @trophy_tracks = Track.where(id: acquired_trophies.map(&:track_id))

    raise "No trophies" unless @num_trophies.positive?

    subject = @num_trophies == 1 ? "You have a new Track Trophy at Exercism" :
      "You have #{@num_trophies.humanize} new Track Trophies at Exercism"

    @email_communication_preferences_key = :receive_product_updates
    bulk_mail(@user, subject)
  end
end
