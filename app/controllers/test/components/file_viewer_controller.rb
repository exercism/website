class Test::Components::FileViewerController < Test::BaseController
  def show
    @language = "ruby"
    @file = {
      filename: "bob.rb",
      content: <<~FILE
        =begin
        Multi
        line comments
        =end

        class Ruby
        end
      FILE
    }
  end
end
