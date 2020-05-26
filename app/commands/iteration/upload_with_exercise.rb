class Iteration
  class UploadWithExercise
    include Mandate

    # This class must NOT access the database
    def initialize(iteration_uuid, exercise_slug, git_sha, track_repo, iteration_files)
      @iteration_uuid = iteration_uuid
      @exercise_slug = exercise_slug
      @git_sha = git_sha
      @track_repo = track_repo
      @iteration_files = iteration_files
      @files_to_upload = {}
    end

    def call
      # Determine the files to upload
      add_iteration_files
      add_exercise_files

      # Then upload them all in parallel
      upload_files
    end

    private
    attr_reader :iteration_uuid, :exercise_slug, :git_sha, :track_repo, :iteration_files, :files_to_upload

    def add_iteration_files
      #TODO Skip files that have non alphanumeric chars
      iteration_files.each do |filename, code|
        next if filename =~ track_repo.test_regexp
        next if filename.starts_with?(".meta")
        next if files_to_upload[filename]
        files_to_upload[filename] = code
      end
    end

    def add_exercise_files
      exercise = track_repo.exercise(exercise_slug, git_sha)
      exercise.filenames.each do |filepath|
        next if filepath =~ track_repo.ignore_regexp
        next if files_to_upload[filepath]
        files_to_upload[filepath] = exercise.read_file_blob(filepath)
      end
    end

    def upload_files
      files_to_upload.map { |filename, code|
        Thread.new { upload_file(filename, code) }
      }.each(&:join)
    end

    def upload_file(filename, code)
      path = "#{Rails.env}/combined/#{iteration_uuid}"

      s3_client = Aws::S3::Client.new(Exercism.config.aws_auth)
      s3_client.put_object(body: code,
                           bucket: Exercism.config.aws_iterations_bucket,
                           key: "#{path}/#{filename}",
                           acl: 'private')
    end
  end
end
