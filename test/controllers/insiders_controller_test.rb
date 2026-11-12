require "test_helper"

class InsidersControllerTest < ActionDispatch::IntegrationTest
  test "show: renders every benefit from the English catalog for a non-insider" do
    get insiders_path

    assert_response :success
    InsidersController::FEATURES.each do |feature|
      assert_select ".features .feature h4", I18n.t("insiders.external.features.#{feature[:key]}.title")
      assert_select ".features .feature p", I18n.t("insiders.external.features.#{feature[:key]}.description")
    end
  end

  test "show: renders the benefits in the visitor's locale for a non-insider" do
    features = { dark_mode: { title: "Sötét mód", description: "Sötét téma leírása" } }
    catalog = { insiders: { external: { features: } } }

    with_published_translations(hu: { backend: catalog }) do
      get "/hu/insiders"
    end

    assert_response :success
    assert_select ".features .feature h4", "Sötét mód"
    assert_select ".features .feature p", "Sötét téma leírása"
  end

  test "join: requires sign in" do
    get join_insiders_path

    assert_redirected_to new_user_session_path
  end

  test "join: renders the form with a same-site return_to" do
    sign_in!(create(:user))

    get join_insiders_path(return_to: "/tracks/jq/exercises/hello-world/edit")

    assert_response :success
    assert_select ".c-react-wrapper-insiders-join[data-react-data*=?]",
      "/tracks/jq/exercises/hello-world/edit"
  end

  test "join: keeps the fragment on return_to, which picks the editor tab" do
    sign_in!(create(:user))

    get join_insiders_path(return_to: "/tracks/jq/exercises/hello-world/edit#assistant")

    assert_response :success
    assert_select ".c-react-wrapper-insiders-join[data-react-data*=?]", "edit#assistant"
  end

  test "join: drops a return_to that is not this site" do
    sign_in!(create(:user))

    get join_insiders_path(return_to: "https://evil.example.com/")

    assert_response :success
    assert_select ".c-react-wrapper-insiders-join[data-react-data*=?]", "evil", count: 0
    assert_select ".c-react-wrapper-insiders-join[data-react-data*=?]", "\"return_to\":\"/insiders\""
  end

  test "join: passes a known trigger on to the form" do
    sign_in!(create(:user))

    get join_insiders_path(trigger: "assistant_upsell_modal")

    assert_select ".c-react-wrapper-insiders-join[data-react-data*=?]", "\"trigger\":\"assistant_upsell_modal\""
  end

  test "join: falls back to its own trigger" do
    sign_in!(create(:user))

    get join_insiders_path(trigger: "somewhere")

    assert_select ".c-react-wrapper-insiders-join[data-react-data*=?]", "\"trigger\":\"insiders_join_page\""
  end

  test "join: an insider is sent straight back" do
    sign_in!(create(:user, :insider))

    get join_insiders_path(return_to: "/tracks/jq/exercises/hello-world/edit")

    assert_redirected_to "/tracks/jq/exercises/hello-world/edit"
  end

  test "payment_pending: passes a same-site return_to through" do
    sign_in!(create(:user))

    get payment_pending_insiders_path(return_to: "/tracks/jq/exercises/hello-world/edit")

    assert_response :success
    assert_select ".c-react-wrapper-insiders-payment-pending[data-react-data*=?]",
      "\"insiders_redirect_path\":\"/tracks/jq/exercises/hello-world/edit\""
  end

  test "payment_pending: falls back to the insiders page" do
    sign_in!(create(:user))

    get payment_pending_insiders_path(return_to: "//evil.example.com")

    assert_response :success
    assert_select ".c-react-wrapper-insiders-payment-pending[data-react-data*=?]",
      "\"insiders_redirect_path\":\"/insiders\""
  end
end
