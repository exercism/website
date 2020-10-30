class Test::Components::Common::CopyToClipboardButtonController < Test::BaseController
  def show
    @text_to_copy = "exercism download --track=csharp --exercise=anagram"
  end
end
