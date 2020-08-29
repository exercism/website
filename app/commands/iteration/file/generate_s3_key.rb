class Iteration
  class File
    class GenerateS3Key
      include Mandate

      initialize_with :iteration_uuid, :filename

      def call
        [
          Rails.env,
          "storage",
          iteration_uuid,
          Digest::SHA1.hexdigest(filename)
        ].join('/')
      end
    end
  end
end
