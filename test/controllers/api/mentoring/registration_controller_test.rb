require_relative '../base_test_case'

class API::Mentoring::RegistrationControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_mentoring_registration_path, method: :post

  ###
  # Create
  ###
  test "create makes someone a mentor" do
    stub_request(:post, "https://dev.null.exercism.io/")

    user = create :user, :not_mentor, reputation: 20
    refute user.mentor? # Sanity check
    setup_user(user)

    ruby = create :track, slug: :ruby
    create :track, slug: :fsharp
    csharp = create :track, slug: :csharp

    post api_mentoring_registration_path,
      params: {
        track_slugs: %w[ruby csharp],
        accept_terms: true
      },
      headers: @headers, as: :json

    # TODO: Check JSON
    assert_response :ok

    assert user.reload.mentor?
    assert_equal [ruby, csharp], user.mentored_tracks
  end
end
