# TODO: (Optional) Remove
module Temp
  class UsersController < ApplicationController
    def destroy
      render json: {
        links: {
          home: Exercism::Routes.temp_user_deletion_url
        }
      }
    end

    def reset
      render json: {
        links: {
          settings: Exercism::Routes.temp_user_reset_url
        }
      }
    end
  end
end
