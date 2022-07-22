require_relative '../base_test_case'

class API::Mentoring::TestimonialsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_mentoring_testimonials_path
  guard_incorrect_token! :reveal_api_mentoring_testimonial_path, args: 1, method: :patch

  ###
  # Index
  ###
  test "index proxies correctly" do
    user = create :user
    setup_user(user)
    page = 15
    track_slug = "ruby"

    Mentor::Testimonial::Retrieve.expects(:call).with(
      mentor: user,
      page:,
      criteria: "Foobar",
      order: "recent",
      track_slug:,
      include_unrevealed: true
    ).returns(Mentor::Testimonial.page(1).per(1))

    get api_mentoring_testimonials_path, params: {
      page:,
      criteria: "Foobar",
      order: "recent",
      track_slug:
    }, headers: @headers, as: :json
  end

  test "index retrieves testimonials" do
    user = create :user
    setup_user(user)

    create :mentor_testimonial, mentor: user, created_at: Time.current - 2.minutes
    5.times { create :mentor_testimonial, mentor: user }

    get api_mentoring_testimonials_path, headers: @headers, as: :json
    assert_response :ok

    expected = SerializePaginatedCollection.(
      Mentor::Testimonial.order(id: :desc).page(1),
      serializer: SerializeMentorTestimonials
    ).to_json

    assert_equal expected, response.body
  end

  ###
  # Reveal
  ###
  test "reveal should 404 if the testimonial doesn't exist" do
    setup_user
    patch reveal_api_mentoring_testimonial_path('xxx'), headers: @headers, as: :json
    assert_response :not_found
  end

  test "reveal should fail on a different person's testimonial" do
    skip
    user = create :user
    setup_user(user)
    testimonial = create :mentor_testimonial

    patch reveal_api_mentoring_testimonial_path(testimonial.uuid), headers: @headers, as: :json

    assert_response :not_found

    refute testimonial.reload.revealed?
  end

  test "reveal should succeed" do
    user = create :user
    setup_user(user)
    testimonial = create :mentor_testimonial, mentor: user

    patch reveal_api_mentoring_testimonial_path(testimonial.uuid), headers: @headers, as: :json

    assert_response :ok

    assert testimonial.reload.revealed?
  end

  test "reveal is rate limited" do
    setup_user

    beginning_of_minute = Time.current.beginning_of_minute
    travel_to beginning_of_minute

    30.times do
      testimonial = create :mentor_testimonial, mentor: @current_user
      patch reveal_api_mentoring_testimonial_path(testimonial.uuid), headers: @headers, as: :json
      assert_response :ok
    end

    testimonial = create :mentor_testimonial, mentor: @current_user
    patch reveal_api_mentoring_testimonial_path(testimonial.uuid), headers: @headers, as: :json
    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to beginning_of_minute + 1.minute

    testimonial = create :mentor_testimonial, mentor: @current_user
    patch reveal_api_mentoring_testimonial_path(testimonial.uuid), headers: @headers, as: :json
    assert_response :ok
  end
end
