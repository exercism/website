module CLI
  class PrepareUploadedFiles
    include Mandate

    initialize_with :http_files

    def call
      http_files.map do |file|
        filename = file.headers.split("\r\n").
                        detect{|s|s.start_with?("Content-Disposition: ")}.
                        split(";").
                        map(&:strip).
                        detect{|s|s.start_with?('filename=')}.
                        split("=").last.
                        gsub('"', '').gsub(/^\//, '')

        content = file.read

        {
          filename: filename,
          content: content,
          digest: IterationFile.generate_digest(content)
        }
      end
    end
  end
end

