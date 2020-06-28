module CLI
  class PrepareUploadedFiles
    include Mandate

    initialize_with :http_files

    def call
      http_files.map do |file|
        filename = file.headers.lines.
          detect { |s| s.start_with?("Content-Disposition: ") }.
          split(";").
          map(&:strip).
          detect { |s| s.start_with?('filename=') }.
          split("=").last.
          delete('"').gsub(%r{^/}, '')

        content = file.read

        {
          filename: filename,
          content: content
        }
      end
    end
  end
end
