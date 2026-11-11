require "test_helper"

class JikiLinksTest < ActionDispatch::IntegrationTest
  test "a signed-in user's links to jiki use their own locale, even on a naked url" do
    user = create :user
    user.update!(locale: "hu")
    sign_in!(user)

    get "/tracks"

    assert_response :ok
    assert_includes response.body, %(href="https://jiki.io/hu?utm_source=exercism&amp;utm_medium=nav")
    refute_match(%r{href="https://jiki\.io[?"]}, response.body)
  end

  test "english users' links to jiki are unprefixed" do
    sign_in!

    get "/tracks"

    assert_response :ok
    assert_includes response.body, %(href="https://jiki.io?utm_source=exercism&amp;utm_medium=nav")
  end

  test "every link to jiki carries utm params" do
    sign_in!

    get "/tracks"

    assert_response :ok
    hrefs = response.body.scan(%r{href="(https://[a-z0-9.]*jiki\.io[^"]*)"}).flatten
    refute_empty hrefs
    hrefs.each do |href|
      assert_includes href, "utm_source=exercism", href
      assert_includes href, "utm_medium=", href
    end
  end

  test "the footer links to jiki are tagged" do
    sign_in!

    get "/tracks"

    assert_includes response.body, %(href="https://jiki.io?utm_source=exercism&amp;utm_medium=footer")
  end

  test "the old bootcamp and courses urls redirect to jiki with utm params" do
    get "/bootcamp"
    assert_redirected_to "https://jiki.io?utm_source=exercism&utm_medium=bootcamp_redirect"

    get "/courses/coding-fundamentals"
    assert_redirected_to "https://jiki.io?utm_source=exercism&utm_medium=courses_redirect"
  end

  test "the sign-up pop-up links to jiki's sign-up page with its seniority" do
    get "/users/sign_up"

    assert_response :ok
    %w[absolute_beginner beginner].each do |seniority|
      assert_includes response.body,
        %(href="https://jiki.io/auth/signup?utm_source=exercism&amp;utm_medium=sign_up&amp;utm_content=#{seniority}")
    end
  end

  test "the returning user modal links to jiki's sign-up page with its seniority" do
    html = ApplicationController.render(partial: "components/returning_user_modal", locals: { tracks: [] })

    %w[absolute_beginner beginner].each do |seniority|
      assert_includes html,
        %(href="https://jiki.io/auth/signup?utm_source=exercism&amp;utm_medium=returning_user&amp;utm_content=#{seniority}")
    end
  end
end
