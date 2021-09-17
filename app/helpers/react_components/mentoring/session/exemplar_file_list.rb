module ReactComponents
  module Mentoring
    class Session
      class ExemplarFileList
        def initialize(files)
          @files = files
        end

        def as_json
          files.map do |filename, content|
            {
              filename: filename.gsub(%r{^\.meta/}, ''),
              content: content
            }
          end
        end

        private
        attr_reader :files
      end
    end
  end
end
