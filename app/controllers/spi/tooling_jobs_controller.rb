module SPI
  class ToolingJobsController < BaseController
    def update
      job = Exercism::ToolingJob.find(params[:id])

      if job.type == "representer"
        ToolingJob::Process.defer(params[:id], wait: 1.hour)
      else
        ToolingJob::Process.(params[:id])
      end
    end
  end
end
