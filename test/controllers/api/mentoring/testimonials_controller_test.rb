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
      page: page,
      criteria: "Foobar",
      order: "recent",
      track_slug: track_slug,
      include_unrevealed: true
    ).returns(Mentor::Testimonial.page(1).per(1))

    get api_mentoring_testimonials_path, params: {
      page: page,
      criteria: "Foobar",
      order: "recent",
      track: track_slug
    }, headers: @headers, as: :json
  end

  test "index retrieves testimonials" do
    user = create :user
    setup_user(user)

    create :mentor_testimonial, mentor: user, created_at: Time.current - 2.minutes
    5.times { create :mentor_testimonial, mentor: user }

    get api_mentoring_testimonials_path, headers: @headers, as: :json
    assert_response 200

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
    assert_response 404
  end

  test "reveal should fail on a different person's testimonial" do
    skip
    user = create :user
    setup_user(user)
    testimonial = create :mentor_testimonial

    patch reveal_api_mentoring_testimonial_path(testimonial.uuid), headers: @headers, as: :json

    assert_response 404

    refute testimonial.reload.revealed?
  end

  test "reveal should succeed" do
    user = create :user
    setup_user(user)
    testimonial = create :mentor_testimonial, mentor: user

    patch reveal_api_mentoring_testimonial_path(testimonial.uuid), headers: @headers, as: :json

    assert_response :success

    assert testimonial.reload.revealed?
  end
end
