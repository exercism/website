module SPI
  class UnsubscribeUsersController < BaseController
    def unsubscribe_by_email
      user = User.find_by(email: params[:email])
      return head :ok unless user

      User::UnsubscribeFromAllEmails.(user)

      begin
        Exercism.ses_client.put_suppressed_destination({
          email_address: params[:email],
          reason: params[:reason].upcase
        })
      rescue Aws::SESV2::Errors::ServiceError => e
        Bugsnag.notify(e)
      end
    end
  end
end
