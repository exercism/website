class ToolingJob::DeleteFromEFS
  include Mandate

  initialize_with :efs_dir

  def call
    return if efs_dir == "/mnt/efs/tooling_jobs/canary"
    return unless Dir.exist?(efs_dir)

    FileUtils.rm_rf(efs_dir)
  end
end
