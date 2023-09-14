module SPI
  class UnsubscribeUsersController < BaseController
    def unsubscribe_by_email
      user = User.find_by!(email: params[:email])
      User::UnsubscribeFromAllEmails.(user)
    end
  end
end
