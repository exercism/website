class ToolingJob::DeleteFromEFS
  include Mandate

  initialize_with :efs_dir

  def call
    return unless Dir.exist?(efs_dir)

    FileUtils.rm_rf(efs_dir)
  end
end
