class ToolingJob::UploadToEFS
  include Mandate

  initialize_with :job_id, :submission

  def call
    return if Dir.exist?(efs_dir)

    submission.files.each do |file|
      efs_path = "#{efs_dir}/#{file.filename}"
      FileUtils.mkdir_p(efs_path.split("/").tap(&:pop).join("/"))
      File.open(efs_path, 'w') { |f| f.write(file.utf8_content) }
    end
  end

  private
  memoize
  def efs_dir
    [Exercism.config.efs_submissions_mount_point, job_id].join('/')
  end
end
