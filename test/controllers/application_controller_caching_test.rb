require "test_helper"

# cache_public_action! bails out in the test environment, so these exercise it
# directly with that guard stubbed out. Without this, nothing covers the
# short-browser-TTL/long-edge-TTL behaviour that the 1.day pages rely on.
class ApplicationControllerCachingTest < ActiveSupport::TestCase
  test "sets a one second browser ttl and a jittered edge ttl" do
    controller = build_controller
    controller.stubs(:user_signed_in?).returns(false)

    controller.send(:cache_public_action!, edge_ttl: 1.day)

    cache_control = controller.response.cache_control
    assert_equal 1, cache_control[:max_age]
    assert cache_control[:public]

    s_maxage = cache_control[:extras].join(",")[/s-maxage=(\d+)/, 1].to_i
    assert s_maxage <= 1.day.to_i
    assert s_maxage >= (1.day.to_i * 0.9).to_i
  end

  test "falls back to the 5-20 minute default without an edge ttl" do
    controller = build_controller
    controller.stubs(:user_signed_in?).returns(false)

    controller.send(:cache_public_action!)

    cache_control = controller.response.cache_control
    assert cache_control[:public]
    assert_empty cache_control[:extras].to_a

    max_age = cache_control[:max_age]
    assert max_age >= 300
    assert max_age <= 1200
  end

  test "does nothing when the user is signed in" do
    controller = build_controller
    controller.stubs(:user_signed_in?).returns(true)

    controller.expects(:expires_in).never

    controller.send(:cache_public_action!, edge_ttl: 1.day)
  end

  test "does nothing when the exercism user cookie is present" do
    controller = build_controller
    controller.stubs(:user_signed_in?).returns(false)
    controller.request.cookie_jar.signed[:_exercism_user_id] = 1

    controller.expects(:expires_in).never

    controller.send(:cache_public_action!, edge_ttl: 1.day)
  end

  def build_controller
    Rails.env.stubs(:test?).returns(false)
    Rails.env.stubs(:development?).returns(false)

    TracksController.new.tap do |controller|
      controller.set_request!(ActionDispatch::TestRequest.create)
      controller.set_response!(ActionDispatch::TestResponse.create)
    end
  end
end
