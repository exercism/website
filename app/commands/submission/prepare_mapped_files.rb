class Submission
  class PrepareMappedFiles
    include Mandate

    initialize_with :files

    def call
      files.map do |filename, content|
        raise SubmissionFileTooLargeError if content.size > 1.megabyte

        {
          filename: filename,
          content: content
        }
      end
    end
  end
end
