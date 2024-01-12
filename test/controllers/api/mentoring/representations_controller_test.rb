require_relative '../base_test_case'

class API::Mentoring::RepresentationsControllerTest < API::BaseTestCase
  include Propshaft::Helper

  guard_incorrect_token! :api_mentoring_representation_path, args: 1, method: :patch
  guard_incorrect_token! :with_feedback_api_mentoring_representations_path
  guard_incorrect_token! :without_feedback_api_mentoring_representations_path

  ##########
  # update #
  ##########
  test "update renders 404 when representation not found" do
    user = create :user
    create(:user_track_mentorship, :automator, user:)
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

  test "update renders 403 if the user is not a automator" do
    setup_user

    representation = create :exercise_representation, num_submissions: 2

    patch api_mentoring_representation_path(representation), headers: @headers, as: :json

    assert_response :forbidden
    expected = {
      error: {
        type: "not_automator",
        message: "You do not have automator permissions for this track"
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "update renders 403 if the user is a automator but not for representation's track" do
    user = create :user
    create :user_track_mentorship, :automator, user:, track: create(:track, :random_slug)
    setup_user(user)

    representation = create :exercise_representation, num_submissions: 2

    patch api_mentoring_representation_path(representation), headers: @headers, as: :json

    assert_response :forbidden
    expected = {
      error: {
        type: "not_automator",
        message: "You do not have automator permissions for this track"
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "updates a representation" do
    exercise = create :practice_exercise
    user = create :user
    create :user_track_mentorship, :automator, user:, track: exercise.track, num_finished_discussions: 100
    setup_user(user)

    representation = create :exercise_representation, last_submitted_at: Time.utc(2012, 6, 20), num_submissions: 2

    patch api_mentoring_representation_path(representation),
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
          icon_url: "https://assets.exercism.org/exercises/strings.svg",
          title: "Strings"
        },
        track: {
          icon_url: "https://assets.exercism.org/tracks/ruby.svg",
          title: "Ruby",
          highlightjs_language: 'ruby'
        },
        num_submissions: 2,
        appears_frequently: false,
        feedback_type: "actionable",
        feedback_markdown: "_great_ work",
        draft_feedback_markdown: nil,
        draft_feedback_type: nil,
        last_submitted_at: "2012-06-20T00:00:00.000Z",
        files: [
          {
            filename: "log_line_parser.rb",
            type: "exercise",
            digest: nil,
            content: "module LogLineParser\n  def self.message(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.message method'\n  end\n\n  def self.log_level(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.log_level method'\n  end\n\n  def self.reformat(line)\n    raise NotImplementedError, 'Please implement the LogLineParser.reformat method'\n  end\nend\n" # rubocop:disable Layout/LineLength,
          }
        ],
        instructions: "<p>In this exercise you'll be processing log-lines.</p>\n<p>Each log line is a string formatted as follows: <code>\"[&lt;LEVEL&gt;]: &lt;MESSAGE&gt;\"</code>.</p>\n<p>There are three different log levels:</p>\n<ul>\n<li><code>INFO</code></li>\n<li><code>WARNING</code></li>\n<li><code>ERROR</code></li>\n</ul>\n<p>You have three tasks, each of which will take a log line and ask you to do something with it.</p>\n<h3 id=\"h-1-get-message-from-a-log-line\">1. Get message from a log line</h3>\n<p>Implement the <code>LogLineParser.message</code> method to return a log line's message:</p>\n<pre><code class=\"language-ruby\">LogLineParser.message('[ERROR]: Invalid operation')\n// Returns: \"Invalid operation\"\n</code></pre>\n<p>Any leading or trailing white space should be removed:</p>\n<pre><code class=\"language-ruby\">LogLineParser.message('[WARNING]:  Disk almost full\\r\\n')\n// Returns: \"Disk almost full\"\n</code></pre>\n<h3 id=\"h-2-get-log-level-from-a-log-line\">2. Get log level from a log line</h3>\n<p>Implement the <code>LogLineParser.log_level</code> method to return a log line's log level, which should be returned in lowercase:</p>\n<pre><code class=\"language-ruby\">LogLineParser.log_level('[ERROR]: Invalid operation')\n// Returns: \"error\"\n</code></pre>\n<h3 id=\"h-3-reformat-a-log-line\">3. Reformat a log line</h3>\n<p>Implement the <code>LogLineParser.reformat</code> method that reformats the log line, putting the message first and the log level after it in parentheses:</p>\n<pre><code class=\"language-ruby\">LogLineParser.reformat('[INFO]: Operation completed')\n// Returns: \"Operation completed (info)\"\n</code></pre>\n", # rubocop:disable Layout/LineLength
        test_files: [
          {
            filename: "log_line_parser_test.rb",
            content: "# frozen_string_literal: true\n\nrequire 'minitest/autorun'\nrequire_relative 'log_line_parser'\n\nclass LogLineParserTest < Minitest::Test\n  def test_error_message\n    assert_equal 'Stack overflow', LogLineParser.message('[ERROR]: Stack overflow')\n  end\n\n  def test_warning_message\n    assert_equal 'Disk almost full', LogLineParser.message('[WARNING]: Disk almost full')\n  end\n\n  def test_info_message\n    assert_equal 'File moved', LogLineParser.message('[INFO]: File moved')\n  end\n\n  def test_message_with_leading_and_trailing_space\n    assert_equal 'Timezone not set', LogLineParser.message(\"[WARNING]:   \\tTimezone not set  \\r\\n\")\n  end\n\n  def test_error_log_level\n    assert_equal 'error', LogLineParser.log_level('[ERROR]: Disk full')\n  end\n\n  def test_warning_log_level\n    assert_equal 'warning', LogLineParser.log_level('[WARNING]: Unsafe password')\n  end\n\n  def test_info_log_level\n    assert_equal 'info', LogLineParser.log_level('[INFO]: Timezone changed')\n  end\n\n  def test_erro_reformat\n    assert_equal 'Segmentation fault (error)', LogLineParser.reformat('[ERROR]: Segmentation fault')\n  end\n\n  def test_warning_reformat\n    assert_equal 'Decreased performance (warning)', LogLineParser.reformat('[WARNING]: Decreased performance')\n  end\n\n  def test_info_reformat\n    assert_equal 'Disk defragmented (info)', LogLineParser.reformat('[INFO]: Disk defragmented')\n  end\n\n  def rest_reformat_with_leading_and_trailing_space\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\n\n  def test_new_test_for_diffs\n    assert_equal 'Corrupt disk (error)', LogLineParser.reformat(\"[ERROR]: \\t Corrupt disk\\t \\t \\r\\n\")\n  end\nend\n" # rubocop:disable Layout/LineLength
          }
        ],
        links: {
          self: "/mentoring/automation/#{representation.uuid}/edit",
          update: "/api/v2/mentoring/representations/#{representation.uuid}"
        }
      }
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "updates sets current user to editor if representation already had author" do
    exercise = create :practice_exercise
    user = create :user
    create :user_track_mentorship, :automator, user:, track: exercise.track, num_finished_discussions: 100
    author = create :user
    setup_user(user)

    representation = create :exercise_representation, feedback_author: author, feedback_markdown: 'Try _this_',
      feedback_type: :essential, feedback_editor: nil, last_submitted_at: Time.utc(2012, 6, 20), num_submissions: 2

    patch api_mentoring_representation_path(representation),
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
    exercise = create :practice_exercise
    user = create :user
    create :user_track_mentorship, :automator, user:, track: exercise.track, num_finished_discussions: 100
    setup_user(user)

    representation = create :exercise_representation, feedback_author: nil, feedback_editor: nil,
      last_submitted_at: Time.utc(2012, 6, 20), num_submissions: 2

    patch api_mentoring_representation_path(representation),
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

  test "update is rate limited" do
    setup_user

    beginning_of_minute = Time.current.beginning_of_minute
    travel_to beginning_of_minute

    exercise = create :practice_exercise
    user = create :user
    create :user_track_mentorship, :automator, user:, track: exercise.track, num_finished_discussions: 100
    setup_user(user)

    representation = create :exercise_representation, last_submitted_at: Time.utc(2012, 6, 20), num_submissions: 2
    params = {
      representation: {
        feedback_markdown: "_great_ work",
        feedback_type: :actionable
      }
    }

    10.times do
      patch api_mentoring_representation_path(representation), params:, headers: @headers, as: :json
      assert_response :ok
    end

    patch api_mentoring_representation_path(representation), params:, headers: @headers, as: :json
    assert_response :too_many_requests

    # Verify that the rate limit resets every minute
    travel_to beginning_of_minute + 1.minute

    patch api_mentoring_representation_path(representation), params:, headers: @headers, as: :json
    assert_response :ok
  end

  ####################
  # without_feedback #
  ####################
  test "without_feedback retrieves representations" do
    track = create :track
    user = create :user
    create(:user_track_mentorship, :automator, user:, track:)
    exercise = create(:practice_exercise, track:)
    setup_user(user)

    representations = Array.new(25) do |idx|
      create(:exercise_representation, num_submissions: 25 - idx, feedback_type: nil, exercise:,
        last_submitted_at: Time.utc(2022, 3, 15) - idx.days, track:)
    end

    params = { track_slug: track.slug }

    get without_feedback_api_mentoring_representations_path, params:, headers: @headers, as: :json
    assert_response :ok

    paginated_representations = Kaminari.paginate_array(representations, total_count: 24).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      serializer_kwargs: { params: },
      meta: {
        # TODO: enable when performance is fixed
        unscoped_total: 0
        # unscoped_total: 25
      }
    )

    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  test "without_feedback renders 403 when user is not a automator" do
    setup_user

    get without_feedback_api_mentoring_representations_path, headers: @headers, as: :json

    assert_response :forbidden
    assert_equal(
      {
        "error" => {
          "type" => "not_automator",
          "message" => "You do not have automator permissions for this track"
        }
      },
      JSON.parse(response.body)
    )
  end

  #################
  # with_feedback #
  #################
  test "with_feedback retrieves representations" do
    track = create :track
    user = create :user
    create(:user_track_mentorship, :automator, user:, track:)
    setup_user(user)

    representations = Array.new(25) do |idx|
      create(:exercise_representation, num_submissions: 25 - idx, feedback_type: :actionable, feedback_author: user,
        last_submitted_at: Time.utc(2022, 3, 15) - idx.days, track:)
    end

    params = { track_slug: track.slug }

    get with_feedback_api_mentoring_representations_path, params:, headers: @headers, as: :json
    assert_response :ok

    paginated_representations = Kaminari.paginate_array(representations, total_count: 24).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      serializer_kwargs: { params: },
      meta: {
        unscoped_total: 25
      }
    )

    assert_equal JSON.parse(expected.to_json), JSON.parse(response.body)
  end

  test "with_feedback renders 403 when user is not a automator" do
    setup_user

    get with_feedback_api_mentoring_representations_path, headers: @headers, as: :json

    assert_response :forbidden
    assert_equal(
      {
        "error" => {
          "type" => "not_automator",
          "message" => "You do not have automator permissions for this track"
        }
      },
      JSON.parse(response.body)
    )
  end
end
