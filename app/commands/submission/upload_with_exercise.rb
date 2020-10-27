class Submission
  class UploadWithExercise
    include Mandate

    # This class must NOT access the database
    def initialize(submission_uuid, submission_files, exercise_files, test_regexp)
      @submission_uuid = submission_uuid
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

      # Return the s3_uri
      "s3://#{submissions_bucket}/#{s3_path}"
    end

    private
    attr_reader :submission_uuid, :submission_files, :exercise_files, :test_regexp, :files_to_upload

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
      s3_client = ExercismConfig::SetupS3Client.()
      s3_client.put_object(body: code,
                           bucket: submissions_bucket,
                           key: "#{s3_path}/#{filename}",
                           acl: 'private')
    end

    memoize
    def submissions_bucket
      Exercism.config.aws_submissions_bucket
    end

    memoize
    def s3_path
      "#{Rails.env}/combined/#{submission_uuid}"
    end
  end
end
