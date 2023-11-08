class Test::Components::Common::CopyToClipboardButtonController < Test::BaseController
  def show
    @text_to_copy = "exercism download --exercise=anagram --track=csharp"
  end
end
