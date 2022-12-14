class SerializeFilesWithMetadata
  include Mandate

  initialize_with :files

  def call
    files.map do |filename, data|
      {
        filename:,
        type: data[:type],
        digest: data[:digest],
        content: data[:content]
      }
    end
  end
end
