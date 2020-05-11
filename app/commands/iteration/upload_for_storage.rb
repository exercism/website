class Iteration
  class UploadForStorage
    include Mandate

    def initialize(iteration_uuid, files)
      @files = files
      @path = "#{Rails.env}/storage/#{iteration_uuid}"
      @files_to_upload = {}
    end

    def call
      files.map { |filename, code|
        Thread.new { upload_file(filename, code) }
      }.each(&:join)
    end

    private
    attr_reader :files, :path

    def upload_file(filename, code)

      # Don't memoize this as it's used in multiple threads
      # Consider moving it safely to a readonly var.
      s3_client = Aws::S3::Client.new(ExercismCredentials.aws_auth)
      s3_client.put_object(body: code,
                           bucket: ExercismCredentials.aws_iterations_bucket,
                           key: "#{path}/#{filename}",
                           acl: 'private')
    end
  end
end
