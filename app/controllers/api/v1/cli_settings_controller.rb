module API
  class CLISettingsController < BaseController
    def show
      render json: {}, status: :ok
    end
  end
end
