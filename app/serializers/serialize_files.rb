class SerializeFiles
  include Mandate

  initialize_with :files

  def call
    files.map do |filename, content|
      {
        filename:,
        content:
      }
    end
  end
end
