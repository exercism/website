require 'test_helper'

class Localization::GlossaryEntriesControllerTest < ActionDispatch::IntegrationTest
  test "redirects to new translator path when user has no translator locales" do
    sign_in!

    get localization_glossary_entries_path

    assert_redirected_to new_localization_translator_path
  end

  test "shows glossary entries when user has translator locales" do
    sign_in!
    @current_user.data.update!(translator_locales: ["pt"])

    get localization_glossary_entries_path

    assert_response :success
  end

  test "show redirects to new translator path when user has no translator locales" do
    sign_in!
    glossary_entry = create :localization_glossary_entry

    get localization_glossary_entry_path(glossary_entry.uuid)

    assert_redirected_to new_localization_translator_path
  end

  test "show works when user has translator locales" do
    sign_in!
    @current_user.data.update!(translator_locales: ["pt"])
    glossary_entry = create :localization_glossary_entry, locale: "pt"

    get localization_glossary_entry_path(glossary_entry.uuid)

    assert_response :success
  end
end
