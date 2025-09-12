require 'test_helper'

class Localization::OriginalsControllerTest < ActionDispatch::IntegrationTest
  test "index redirects to new translator path when user has no translator locales" do
    sign_in!

    get localization_originals_path

    assert_redirected_to new_localization_translator_path
  end

  test "show redirects to new translator path when user has no translator locales" do
    sign_in!
    original = create :localization_original

    get localization_original_path(original.uuid)

    assert_redirected_to new_localization_translator_path
  end

  test "show works when user has translator locales" do
    sign_in!
    @current_user.data.update!(translator_locales: ["pt"])
    original = create :localization_original
    create :localization_translation, key: original.key, locale: "pt"

    get localization_original_path(original.uuid)

    assert_response :success
  end
end
