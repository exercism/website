class SerializeFiles
  include Mandate

  initialize_with :files

  def call
    files.map do |filename, data|
      {
        filename: filename,
        type: data[:type],
        content: data[:content]
      }
    end
  end
end
