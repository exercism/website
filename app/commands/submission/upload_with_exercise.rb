class Submission
  class UploadWithExercise
    include Mandate

    # This class must NOT access the database
    def initialize(submission_uuid, exercise_slug, git_sha, track_repo, submission_files)
      @submission_uuid = submission_uuid
      @exercise_slug = exercise_slug
      @git_sha = git_sha
      @track_repo = track_repo
      @submission_files = submission_files
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
    attr_reader :submission_uuid, :exercise_slug, :git_sha, :track_repo, :submission_files, :files_to_upload

    def add_submission_files
      # TODO: Skip files that have non alphanumeric chars
      submission_files.each do |file|
        filename = file[:filename]

        next if filename.match?(track_repo.test_regexp)
        next if filename.starts_with?(".meta")
        next if files_to_upload[filename]

        files_to_upload[filename] = file[:content]
      end
    end

    def add_exercise_files
      exercise = track_repo.exercise(exercise_slug, git_sha)
      exercise.filepaths.each do |filepath|
        next if filepath.match?(track_repo.ignore_regexp)
        next if files_to_upload[filepath]

        files_to_upload[filepath] = exercise.read_file_blob(filepath)
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
