class Iteration
  class UploadForStorage
    include Mandate

    def initialize(iteration_uuid, files)
      @iteration_uuid = iteration_uuid
      @files = files
    end

    def call
      files.map do |file|
        Thread.new { upload_file(file[:filename], file[:content]) }
      end.each(&:join)
    end

    private
    attr_reader :iteration_uuid, :files

    def upload_file(filename, code)
      path = "#{Rails.env}/storage/#{iteration_uuid}"

      # Don't memoize this as it's used in multiple threads
      # Consider moving it safely to a readonly var.
      s3_client = Aws::S3::Client.new(Exercism.config.aws_auth)
      s3_client.put_object(body: code,
                           bucket: Exercism.config.aws_iterations_bucket,
                           key: "#{path}/#{filename}",
                           acl: 'private')
    end
  end
end
