require_relative '../base_test_case'

class API::Mentoring::RepresentationsControllerTest < API::BaseTestCase
  include Propshaft::Helper

  guard_incorrect_token! :api_mentoring_representation_path, args: 1, method: :patch
  guard_incorrect_token! :with_feedback_api_mentoring_representations_path
  guard_incorrect_token! :without_feedback_api_mentoring_representations_path
  guard_incorrect_token! :tracks_with_feedback_api_mentoring_representations_path
  guard_incorrect_token! :tracks_without_feedback_api_mentoring_representations_path

  ##########
  # update #
  ##########
  test "update renders 404 when representation not found" do
    user = create :user, :supermentor
    setup_user(user)

    patch api_mentoring_representation_path('xxx'), headers: @headers, as: :json

    assert_response :not_found
    expected = {
      error: {
        type: "representation_not_found",
        message: "This representation could not be found"
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "update renders 403 if the user is not a supermentor" do
    setup_user

    representation = create :exercise_representation

    patch api_mentoring_representation_path(representation.uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = {
      error: {
        type: "not_supermentor",
        message: "You do not have supermentor permissions"
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "updates a representation" do
    user = create :user, :supermentor
    setup_user(user)

    representation = create :exercise_representation, last_submitted_at: Time.utc(2012, 6, 20)

    patch api_mentoring_representation_path(representation.uuid),
      params: {
        representation: {
          feedback_markdown: "_great_ work",
          feedback_type: :actionable
        }
      },
      headers: @headers,
      as: :json

    assert_response :ok
    expected = {
      representation: {
        id: representation.id,
        exercise: {
          icon_url: "https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/strings.svg",
          title: "Strings"
        },
        track: {
          icon_url: "https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg",
          title: "Ruby"
        },
        num_submissions: 0,
        appears_frequently: false,
        feedback_markdown: "_great_ work",
        last_submitted_at: "2012-06-20T00:00:00.000Z",
        links: {}
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "updates sets current user to editor if representation already had author" do
    user = create :user, :supermentor
    author = create :user
    setup_user(user)

    representation = create :exercise_representation, feedback_author: author, feedback_editor: nil,
      last_submitted_at: Time.utc(2012, 6, 20)

    patch api_mentoring_representation_path(representation.uuid),
      params: {
        representation: {
          feedback_markdown: "_great_ work",
          feedback_type: :actionable
        }
      },
      headers: @headers,
      as: :json

    representation.reload
    assert_response :ok
    assert_equal user, representation.feedback_editor
    assert_equal author, representation.feedback_author
  end

  test "updates sets current user to author if representation doesn't have author" do
    user = create :user, :supermentor
    setup_user(user)

    representation = create :exercise_representation, feedback_author: nil, feedback_editor: nil,
      last_submitted_at: Time.utc(2012, 6, 20)

    patch api_mentoring_representation_path(representation.uuid),
      params: {
        representation: {
          feedback_markdown: "_great_ work",
          feedback_type: :actionable
        }
      },
      headers: @headers,
      as: :json

    representation.reload
    assert_response :ok
    assert_equal user, representation.feedback_author
    assert_nil representation.feedback_editor
  end

  ####################
  # without_feedback #
  ####################
  test "without_feedback retrieves representations" do
    track = create :track
    user = create :user, :supermentor
    create :user_track_mentorship, user: user, track: track
    exercise = create :practice_exercise, track: track
    setup_user(user)

    representations = Array.new(25) do |idx|
      create :exercise_representation, num_submissions: 25 - idx, feedback_type: nil, exercise: exercise
    end

    get without_feedback_api_mentoring_representations_path, headers: @headers, as: :json
    assert_response :ok

    paginated_representations = Kaminari.paginate_array(representations, total_count: 25).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      meta: {
        unscoped_total: 25
      }
    )
    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  test "without_feedback renders 403 when user is not a supermentor" do
    setup_user

    get without_feedback_api_mentoring_representations_path, headers: @headers, as: :json

    assert_response :forbidden
    assert_equal(
      {
        "error" => {
          "type" => "not_supermentor",
          "message" => "You do not have supermentor permissions"
        }
      },
      JSON.parse(response.body)
    )
  end

  #################
  # with_feedback #
  #################
  test "with_feedback retrieves representations" do
    user = create :user, :supermentor
    setup_user(user)

    representations = Array.new(25) do |idx|
      create :exercise_representation, num_submissions: 25 - idx, feedback_type: :actionable, feedback_author: user
    end

    get with_feedback_api_mentoring_representations_path, headers: @headers, as: :json
    assert_response :ok

    paginated_representations = Kaminari.paginate_array(representations, total_count: 25).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      meta: {
        unscoped_total: 25
      }
    )

    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  test "with_feedback renders 403 when user is not a supermentor" do
    setup_user

    get with_feedback_api_mentoring_representations_path, headers: @headers, as: :json

    assert_response :forbidden
    assert_equal(
      {
        "error" => {
          "type" => "not_supermentor",
          "message" => "You do not have supermentor permissions"
        }
      },
      JSON.parse(response.body)
    )
  end

  ########################
  # tracks_with_feedback #
  ########################
  test "tracks_without_feedback retrieves all tracks the user has given feedback on" do
    user = create :user, :supermentor
    setup_user(user)

    ruby = create :track, title: "Ruby", slug: "ruby"
    go = create :track, title: "Go", slug: "go"

    create :user_track_mentorship, user: user, track: ruby
    create :user_track_mentorship, user: user, track: go

    series = create :concept_exercise, title: "Series", track: ruby
    tournament = create :concept_exercise, title: "Tournament", track: go

    create :exercise_representation, exercise: series, feedback_type: nil
    create :exercise_representation, exercise: series, feedback_type: nil
    create :exercise_representation, exercise: tournament, feedback_type: nil
    create :exercise_representation, exercise: series, feedback_type: :actionable, feedback_author: user # Sanity check

    get tracks_without_feedback_api_mentoring_representations_path, headers: @headers, as: :json
    assert_response :ok

    expected = [
      { slug: nil, title: 'All Tracks', icon_url: "ICON", num_submissions: 3 },
      { slug: go.slug, title: go.title, icon_url: go.icon_url, num_submissions: 1 },
      { slug: ruby.slug, title: ruby.title, icon_url: ruby.icon_url, num_submissions: 2 }
    ]
    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  test "tracks_without_feedback renders 403 when user is not a supermentor" do
    setup_user

    get tracks_without_feedback_api_mentoring_representations_path, headers: @headers, as: :json

    assert_response :forbidden
    assert_equal(
      {
        "error" => {
          "type" => "not_supermentor",
          "message" => "You do not have supermentor permissions"
        }
      },
      JSON.parse(response.body)
    )
  end

  ########################
  # tracks_with_feedback #
  ########################
  test "tracks_with_feedback retrieves all tracks the user has given feedback on" do
    user = create :user, :supermentor
    setup_user(user)

    ruby = create :track, title: "Ruby", slug: "ruby"
    go = create :track, title: "Go", slug: "go"

    create :user_track_mentorship, user: user, track: ruby
    create :user_track_mentorship, user: user, track: go

    series = create :concept_exercise, title: "Series", track: ruby
    tournament = create :concept_exercise, title: "Tournament", track: go

    create :exercise_representation, exercise: series, feedback_type: :actionable, feedback_author: user
    create :exercise_representation, exercise: series, feedback_type: :essential, feedback_editor: user
    create :exercise_representation, exercise: tournament, feedback_type: :essential, feedback_author: user
    create :exercise_representation, exercise: tournament, feedback_type: nil # Sanity check

    get tracks_with_feedback_api_mentoring_representations_path, headers: @headers, as: :json
    assert_response :ok

    expected = [
      { slug: nil, title: 'All Tracks', icon_url: "ICON", num_submissions: 3 },
      { slug: go.slug, title: go.title, icon_url: go.icon_url, num_submissions: 1 },
      { slug: ruby.slug, title: ruby.title, icon_url: ruby.icon_url, num_submissions: 2 }
    ]
    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  test "tracks_with_feedback renders 403 when user is not a supermentor" do
    setup_user

    get tracks_with_feedback_api_mentoring_representations_path, headers: @headers, as: :json

    assert_response :forbidden
    assert_equal(
      {
        "error" => {
          "type" => "not_supermentor",
          "message" => "You do not have supermentor permissions"
        }
      },
      JSON.parse(response.body)
    )
  end
end
