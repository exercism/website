module HasToolingJob
  extend ActiveSupport::Concern
  extend Mandate::Memoize

  private
  memoize
  def tooling_job
    Exercism::ToolingJob.new(tooling_job_id, {})
  end

  included do
    delegate :stdout, :stderr, :metadata, to: :tooling_job
  end
end
