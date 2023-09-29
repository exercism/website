require "test_helper"

class Mentoring::AutomationControllerTest < ActionDispatch::IntegrationTest
  %i[admin staff].each do |role|
    test "index: renders correctly for #{role}" do
      track = create :track
      user = create :user, role
      create(:exercise_representation, feedback_type: nil, num_submissions: 3, track:)
      create(:user_track_mentorship, user:, track:)
      sign_in!(user)

      get mentoring_automation_index_path

      assert_template "mentoring/automation/index"
    end
  end

  test "index: renders correctly for automator" do
    track = create :track
    user = create :user
    create(:exercise_representation, feedback_type: nil, num_submissions: 3, track:)
    create(:user_track_mentorship, :automator, user:, track:)
    sign_in!(user)

    get mentoring_automation_index_path

    assert_template "mentoring/automation/index"
  end

  test "index: redirects non automators" do
    user = create :user
    create(:user_track_mentorship, user:)
    sign_in!(user)

    get mentoring_automation_index_path
    assert_redirected_to mentoring_path
  end

  test "index: renders correct for filtered track automator" do
    track = create :track
    user = create :user
    create(:user_track_mentorship, :automator, user:, track:)
    sign_in!(user)

    get mentoring_automation_index_path(track_slug: track.slug)
    assert_template "mentoring/automation/index"
  end

  test "with_feedback: renders correctly for automator" do
    user = create :user
    create(:user_track_mentorship, :automator, user:)
    sign_in!(user)

    get with_feedback_mentoring_automation_index_path

    assert_template "mentoring/automation/with_feedback"
  end

  test "with_feedback: redirects non automators" do
    user = create :user
    create(:user_track_mentorship, user:)
    sign_in!(user)

    get with_feedback_mentoring_automation_index_path
    assert_redirected_to mentoring_path
  end

  test "with_feedback: renders correct for filtered track automator" do
    track = create :track
    user = create :user
    create(:user_track_mentorship, :automator, user:, track:)
    sign_in!(user)

    get with_feedback_mentoring_automation_index_path(track_slug: track.slug)
    assert_template "mentoring/automation/with_feedback"
  end

  test "edit: renders correct for automators" do
    exercise = create :practice_exercise
    user = create :user
    create :user_track_mentorship, :automator, user:, track: exercise.track, num_finished_discussions: 100
    sign_in!(user)

    representation = create(:exercise_representation, exercise:)
    get edit_mentoring_automation_path(representation)

    assert_template "mentoring/automation/edit"
  end

  test "edit: raises when representation could not be found" do
    user = create :user
    create(:user_track_mentorship, :automator, user:)
    sign_in!(user)

    assert_raises ActiveRecord::RecordNotFound do
      get edit_mentoring_automation_path('XXX')
    end
  end

  test "edit: redirects non automators" do
    user = create :user
    create(:user_track_mentorship, user:)
    sign_in!(user)

    representation = create :exercise_representation

    get edit_mentoring_automation_path(representation)
    assert_redirected_to mentoring_path
  end

  test "edit: redirects automator that is not an automator for the filtered track" do
    track = create :track
    user = create :user
    create(:user_track_mentorship, user:, track:)
    create :user_track_mentorship, :automator, user:, track: create(:track, :random_slug)
    sign_in!(user)

    representation = create(:exercise_representation, track:)

    get edit_mentoring_automation_path(representation)
    assert_redirected_to mentoring_path
  end

  test "tooltip_locked: renders correctly for automator" do
    user = create :user
    create(:user_track_mentorship, :automator, user:)
    sign_in!(user)

    get tooltip_locked_mentoring_automation_index_path

    assert_template "mentoring/automation/tooltip_locked"
  end

  test "tooltip_locked: renders correctly for non automator" do
    user = create :user
    create(:user_track_mentorship, user:)
    sign_in!(user)

    get tooltip_locked_mentoring_automation_index_path

    assert_template "mentoring/automation/tooltip_locked"
  end
end
