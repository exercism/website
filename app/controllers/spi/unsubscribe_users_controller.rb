module SPI
  class UnsubscribeUsersController < BaseController
    def unsubscribe_by_email
      user = User.find_by!(email: params[:email])
      User::UnsubscribeFromAllEmails.(user)

      Exercism.ses_client.put_suppressed_destination({
        email_address: params[:email],
        reason: params[:reason].upcase
      })
    end
  end
end
