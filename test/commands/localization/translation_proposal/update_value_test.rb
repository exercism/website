require 'test_helper'

class Localization::TranslationProposal::UpdateValueTest < ActiveSupport::TestCase
  test "proposal value gets updated" do
    user = create :user
    original = create :localization_original
    translation = create :localization_translation, key: original.key, locale: "en"
    proposal = create :localization_translation_proposal, translation: translation, proposer: user, value: "Something wiiiiiild"

    Localization::TranslationProposal::UpdateValue.(proposal, user, "New value")

    assert_equal "New value", proposal.reload.value
  end
end
