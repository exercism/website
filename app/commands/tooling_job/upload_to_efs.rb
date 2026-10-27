class ToolingJob::UploadToEFS
  include Mandate

  initialize_with :efs_dir, :submission_files

  def call
    return if Dir.exist?(efs_dir)

    submission_files.each do |file|
      efs_path = File.expand_path(File.join(base_dir, file.filename))

      # Only write files that sit inside the job's directory
      next unless efs_path.start_with?("#{base_dir}/")

      FileUtils.mkdir_p(File.dirname(efs_path), mode: 0o777)
      File.open(efs_path, 'w') { |f| f.write(file.utf8_content) }
    end
  end

  private
  memoize
  def base_dir = File.expand_path(efs_dir)
end
