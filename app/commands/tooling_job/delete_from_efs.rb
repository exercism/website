class ToolingJob::DeleteFromEFS
  include Mandate

  initialize_with :job_id

  def call
    return unless Dir.exist?(efs_dir)

    FileUtils.rm_rf(efs_dir)
  end

  private
  memoize
  def efs_dir
    [Exercism.config.efs_submissions_mount_point, job_id].join('/')
  end
end
