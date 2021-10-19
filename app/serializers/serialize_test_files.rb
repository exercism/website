class SerializeTestFiles
  include Mandate

  initialize_with :files

  def call
    files.map do |filename, content|
      {
        filename: filename,
        content: content
      }
    end
  end
end
