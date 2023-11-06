module TrainingData
  class DashboardController < ApplicationController
    def index
      @training_data_dashboard_params = params.permit(:status, :order, :criteria, :page, :track_slug)
      @statuses = TrainingData::CodeTagsSample.statuses
    end
  end
end
