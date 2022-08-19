require_relative '../base_test_case'

class API::Mentoring::RepresentationsControllerTest < API::BaseTestCase
  include Propshaft::Helper

  guard_incorrect_token! :with_feedback_api_mentoring_representations_path
  guard_incorrect_token! :without_feedback_api_mentoring_representations_path
  guard_incorrect_token! :tracks_with_feedback_api_mentoring_representations_path
  guard_incorrect_token! :tracks_without_feedback_api_mentoring_representations_path

  ###
  # without_feedback
  ###
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
          "type" => "no_supermentor",
          "message" => "You do not have supermentor permissions"
        }
      },
      JSON.parse(response.body)
    )
  end

  ###
  # with_feedback
  ###
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
          "type" => "no_supermentor",
          "message" => "You do not have supermentor permissions"
        }
      },
      JSON.parse(response.body)
    )
  end

  ###
  # tracks_with_feedback
  ###
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
          "type" => "no_supermentor",
          "message" => "You do not have supermentor permissions"
        }
      },
      JSON.parse(response.body)
    )
  end

  ###
  # tracks_with_feedback
  ###
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
          "type" => "no_supermentor",
          "message" => "You do not have supermentor permissions"
        }
      },
      JSON.parse(response.body)
    )
  end
end
