require "test_helper"

class ViewComponents::ReturningUserModalTest < ActiveSupport::TestCase
  # Each test stubs only what its path through #to_s reaches, because Mocha
  # here fails a test that stubs a method it never calls.

  test "shows to a user who signed up before the sign-up page asked for seniority" do
    user = create :user, seniority: nil, created_at: cutoff - 1.day
    tracks = [create(:track, slug: "go")]
    Track::RetrieveSignUpCodeCheckTracks.stubs(:call).returns(tracks)
    session = {}
    component = signed_in_component(user)
    component.stubs(session:)
    component.expects(:showing_modal!)
    component.expects(:render).with("components/returning_user_modal", tracks:).returns("modal")

    assert_equal "modal", component.to_s
    assert session[ViewComponents::ReturningUserModal::SHOWN_AT_FLAG].present?
  end

  test "never shows to a user who signed up after the sign-up page asked for seniority" do
    user = create :user, seniority: nil, created_at: cutoff + 1.second
    component = signed_in_component(user)
    component.expects(:showing_modal!).never

    assert_nil component.to_s
  end

  test "does not show to a user who has a seniority" do
    user = create :user, seniority: :mid, created_at: cutoff - 1.day

    assert_nil signed_in_component(user).to_s
  end

  test "does not show if another modal is showing" do
    component = ViewComponents::ReturningUserModal.new
    component.stubs(user_signed_in?: true, showing_modal?: true)

    assert_nil component.to_s
  end

  test "does not show to someone signed out" do
    component = ViewComponents::ReturningUserModal.new
    component.stubs(user_signed_in?: false)

    assert_nil component.to_s
  end

  private
  def cutoff = User::DetermineIfOnboardingAsksSeniority::SIGN_UP_ASKS_SENIORITY_FROM

  def signed_in_component(user)
    ViewComponents::ReturningUserModal.new.tap do |component|
      component.stubs(user_signed_in?: true, showing_modal?: false, current_user: user)
    end
  end
end
