module SPI
  class ToolingJobsController < BaseController
    def update
      ToolingJob.process!(params[:id])
    end
  end
end
