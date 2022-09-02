module SPI
  class ToolingJobsController < BaseController
    def update
      ToolingJob::Process.(params[:id])
    end
  end
end
