require "test_helper"

class ViewComponents::ReturningUserModalTest < ActiveSupport::TestCase
  test "shows to a user who signed up before the sign-up page asked for seniority" do
    user = create :user, seniority: nil, created_at: cutoff - 1.day
    tracks = [create(:track, slug: "go")]
    Track::RetrieveSignUpCodeCheckTracks.stubs(:call).returns(tracks)
    session = {}
    component = component_for(user, session:)
    component.expects(:render).with("components/returning_user_modal", tracks:).returns("modal")
    component.expects(:showing_modal!)

    assert_equal "modal", component.to_s
    assert session[ViewComponents::ReturningUserModal::SHOWN_AT_FLAG].present?
  end

  test "never shows to a user who signed up after the sign-up page asked for seniority" do
    user = create :user, seniority: nil, created_at: cutoff + 1.second
    session = {}

    assert_nil component_for(user, session:).to_s
    assert_nil session[ViewComponents::ReturningUserModal::SHOWN_AT_FLAG]
  end

  test "does not show to a user who has a seniority" do
    user = create :user, seniority: :mid, created_at: cutoff - 1.day

    assert_nil component_for(user).to_s
  end

  test "does not show if another modal is showing" do
    user = create :user, seniority: nil, created_at: cutoff - 1.day

    assert_nil component_for(user, showing_modal: true).to_s
  end

  test "does not show to someone signed out" do
    component = ViewComponents::ReturningUserModal.new
    component.stubs(user_signed_in?: false)

    assert_nil component.to_s
  end

  private
  def cutoff = User::DetermineIfOnboardingAsksSeniority::SIGN_UP_ASKS_SENIORITY_FROM

  def component_for(user, session: {}, showing_modal: false)
    ViewComponents::ReturningUserModal.new.tap do |component|
      component.stubs(user_signed_in?: true, current_user: user, session:)
      component.stubs(:showing_modal?).returns(showing_modal)
      component.stubs(:showing_modal!)
    end
  end
end
