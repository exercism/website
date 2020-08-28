class Iteration
  class UploadForStorage
    include Mandate

    initialize_with :iteration_uuid, :files

    def call
      files.map do |file|
        Thread.new { upload_file(file[:filename], file[:content]) }
      end.each(&:join)
    end

    private
    def upload_file(filename, code)
      key = Iteration::File::GenerateS3Key.(iteration_uuid, filename)

      s3_client = ExercismConfig::SetupS3Client.()
      s3_client.put_object(bucket: Exercism.config.aws_iterations_bucket,
                           key: key,
                           body: code,
                           acl: 'private')
    end
  end
end
