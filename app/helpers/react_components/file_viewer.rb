module ReactComponents
  class FileViewer < ReactComponent
    initialize_with :language, :file

    def to_s
      super(
        "file-viewer",
        { language: language, file: file }
      )
    end
  end
end
