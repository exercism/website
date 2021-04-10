require_relative '../base_test_case'

class API::Profiles::MentorTestimonialsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_profile_testimonials_path, args: 1

  ###
  # Index
  ###
  test "index proxies correctly" do
    setup_user

    profile_user = create(:user_profile).user
    page = 15
    track_slug = "ruby"

    Mentor::Testimonial::Retrieve.expects(:call).with(
      mentor: profile_user,
      page: page,
      criteria: "Foobar",
      order: "recent",
      track_slug: track_slug,
      include_unrevealed: false
    ).returns(Mentor::Testimonial.page(1).per(1))

    get api_profile_testimonials_path(profile_user), params: {
      page: page,
      criteria: "Foobar",
      order: "recent",
      track_slug: track_slug
    }, headers: @headers, as: :json
  end

  test "index retrieves testimonials" do
    setup_user

    profile_user = create(:user_profile).user
    create :mentor_testimonial, :revealed, mentor: profile_user, created_at: Time.current - 2.minutes
    5.times { create :mentor_testimonial, :revealed, mentor: profile_user }

    get api_profile_testimonials_path(profile_user), headers: @headers, as: :json
    assert_response 200

    expected = SerializePaginatedCollection.(
      Mentor::Testimonial.order(id: :desc).page(1),
      serializer: SerializeMentorTestimonials
    ).to_json

    assert_equal expected, response.body
  end
end
