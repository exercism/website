require_relative '../base_test_case'

class API::Mentoring::StudentsControllerTest < API::BaseTestCase
  guard_incorrect_token! :favorite_api_mentoring_student_path, args: 1, method: :post
  guard_incorrect_token! :favorite_api_mentoring_student_path, args: 1, method: :delete

  guard_incorrect_token! :block_api_mentoring_student_path, args: 1, method: :post
  guard_incorrect_token! :block_api_mentoring_student_path, args: 1, method: :delete

  ###
  # Favorite
  ###
  test "favorite should 404 if the student doesn't exist" do
    setup_user

    post favorite_api_mentoring_student_path('xxx'), headers: @headers, as: :json
    assert_response :bad_request
    expected = { error: {
      type: "invalid_mentor_student_relationship",
      message: I18n.t('api.errors.invalid_mentor_student_relationship')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  # TODO: Check whether 400 is valid when the toggle_favorite fails
  # due to there not being a discussion between student and mentor

  test "favorite should 200 if valid" do
    mentor = create :user
    student = create :user

    create :mentor_discussion, mentor:, solution: create(:concept_solution, user: student)

    setup_user(mentor)
    post favorite_api_mentoring_student_path(student.handle), headers: @headers, as: :json
    assert_response :ok

    assert Mentor::StudentRelationship.where(mentor:, student:, favorited: true).exists?
  end

  ###
  # Unfavorite
  ###
  test "Unfavorite should 404 if the student doesn't exist" do
    setup_user

    delete favorite_api_mentoring_student_path('xxx'), headers: @headers, as: :json
    assert_response :bad_request
    expected = { error: {
      type: "invalid_mentor_student_relationship",
      message: I18n.t('api.errors.invalid_mentor_student_relationship')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  # TODO: Check whether 400 is valid when the toggle_favorite fails
  # due to there not being a discussion between student and mentor

  test "Unfavorite should 200 if valid" do
    mentor = create :user
    student = create :user

    create :mentor_discussion, mentor:, solution: create(:concept_solution, user: student)

    setup_user(mentor)
    delete favorite_api_mentoring_student_path(student.handle), headers: @headers, as: :json
    assert_response :ok

    assert Mentor::StudentRelationship.where(mentor:, student:, favorited: false).exists?
  end

  ###
  # Block
  ###
  test "block should 404 if the student doesn't exist" do
    setup_user

    post block_api_mentoring_student_path('xxx'), headers: @headers, as: :json
    assert_response :bad_request
    expected = { error: {
      type: "invalid_mentor_student_relationship",
      message: I18n.t('api.errors.invalid_mentor_student_relationship')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  # TODO: Check whether 400 is valid when the toggle_block fails
  # due to there not being a discussion between student and mentor

  test "block should 200 if valid" do
    mentor = create :user
    student = create :user

    create :mentor_discussion, mentor:, solution: create(:concept_solution, user: student)

    setup_user(mentor)
    post block_api_mentoring_student_path(student.handle), headers: @headers, as: :json
    assert_response :ok

    assert Mentor::StudentRelationship.where(mentor:, student:, blocked_by_mentor: true).exists?
  end

  ###
  # Unblock
  ###
  test "unblock should 404 if the student doesn't exist" do
    setup_user

    delete block_api_mentoring_student_path('xxx'), headers: @headers, as: :json
    assert_response :bad_request
    expected = { error: {
      type: "invalid_mentor_student_relationship",
      message: I18n.t('api.errors.invalid_mentor_student_relationship')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  # TODO: Check whether 400 is valid when the toggle_block fails
  # due to there not being a discussion between student and mentor

  test "unblock should 200 if valid" do
    mentor = create :user
    student = create :user

    create :mentor_discussion, mentor:, solution: create(:concept_solution, user: student)

    setup_user(mentor)
    delete block_api_mentoring_student_path(student.handle), headers: @headers, as: :json
    assert_response :ok

    assert Mentor::StudentRelationship.where(mentor:, student:, blocked_by_mentor: false).exists?
  end
end
