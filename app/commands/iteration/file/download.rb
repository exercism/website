class Iteration
  class File
    class Download
      include Mandate

      initialize_with :iteration_uuid, :filename

      def initialize(iteration_uuid, filename)
        @iteration_uuid = iteration_uuid
        @filename = filename
      end

      def call
        key = GenerateS3Key.(iteration_uuid, filename)

        s3_client = ExercismConfig::SetupS3Client.()
        obj = s3_client.get_object(bucket: Exercism.config.aws_iterations_bucket,
                                   key: key)
        obj.body.read
      end
    end
  end
end
