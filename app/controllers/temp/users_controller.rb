# TODO: Remove
module Temp
  class UsersController < ApplicationController
    def destroy
      render json: {
        links: {
          home: Exercism::Routes.temp_user_deletion_url
        }
      }
    end
  end
end
