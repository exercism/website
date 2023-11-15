module TrainingData
  class DashboardController < ApplicationController
    before_action :guard_trainer!

    def index
      @training_data_dashboard_params = params.permit(:status, :order, :criteria, :page, :track_slug)
      @statuses = TrainingData::CodeTagsSample.statuses.keys.map(&:to_s)
    end

    def guard_trainer!
      return true if current_user&.trainer?

      redirect_to training_data_external_path
    end
  end
end
