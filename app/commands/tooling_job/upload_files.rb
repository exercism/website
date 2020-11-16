class ToolingJob
  class UploadFiles
    include Mandate

    # This class must NOT access the database
    def initialize(job_id, submission_files, exercise_files, test_regexp)
      @job_id = job_id
      @submission_files = submission_files
      @exercise_files = exercise_files
      @test_regexp = test_regexp
      @files_to_upload = {}
    end

    def call
      # Determine the files to upload
      add_submission_files
      add_exercise_files

      # Then upload them all in parallel
      upload_files
    end

    private
    attr_reader :job_id, :submission_files, :exercise_files, :test_regexp, :files_to_upload

    def add_submission_files
      # TODO: Skip files that have non alphanumeric chars
      submission_files.each do |file|
        filename = file[:filename]

        next if filename.match?(test_regexp)
        next if filename.starts_with?(".meta")
        next if files_to_upload[filename]

        files_to_upload[filename] = file[:content]
      end
    end

    def add_exercise_files
      exercise_files.each do |filepath, contents|
        next if files_to_upload[filepath]

        files_to_upload[filepath] = contents
      end
    end

    def upload_files
      files_to_upload.map do |filename, code|
        Thread.new { upload_file(filename, code) }
      end.each(&:join)
    end

    def upload_file(filename, code)
      filepath = "#{folder}/#{filename}"
      FileUtils.mkdir_p(filepath.split("/").tap(&:pop).join("/"))
      File.write(filepath, code)
    end

    memoize
    def folder
      return "/mnt/tooling_jobs/#{job_id}" if Rails.env.production?

      "/tmp/exercism-tooling-jobs-efs/#{job_id}"
    end
  end
end
