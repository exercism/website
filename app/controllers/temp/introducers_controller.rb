# TODO: Remove
module Temp
  class IntroducersController < ApplicationController
    # TODO: This is just a temporary implementation
    def hide
      session[:hidden_introducers] = [params[:id]]

      render json: {}
    end
  end
end
