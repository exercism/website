require_relative './base_test_case'

class API::MentorFavoritesControllerTest < API::BaseTestCase
  ###
  # Create
  ###
  test "create should return 401 with incorrect token" do
    post api_mentor_favorite_student_path(student_handle: 'xxx'), headers: @headers, as: :json
    assert_response 401
  end

  test "create should 404 if the student doesn't exist" do
    setup_user

    post api_mentor_favorite_student_path(student_handle: 'xxx'), headers: @headers, as: :json
    assert_response 400
    expected = { error: {
      type: "invalid_mentor_student_relationship",
      message: I18n.t('api.errors.invalid_mentor_student_relationship')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  # TODO: Check whether 400 is valid when the toggle_favorite fails
  # due to there not being a discussion between student and mentor

  test "create should 200 if valid" do
    mentor = create :user
    student = create :user

    create :solution_mentor_discussion, mentor: mentor, solution: create(:concept_solution, user: student)

    setup_user(mentor)
    post api_mentor_favorite_student_path(student_handle: student.handle), headers: @headers, as: :json
    assert_response 200

    assert Mentor::StudentRelationship.where(mentor: mentor, student: student, favorite: true).exists?
  end

  ###
  # Destroy
  ###
  test "delete should return 401 with incorrect token" do
    delete api_mentor_unfavorite_student_path(student_handle: 'xxx'), headers: @headers, as: :json
    assert_response 401
  end

  test "delete should 404 if the student doesn't exist" do
    setup_user

    delete api_mentor_unfavorite_student_path(student_handle: 'xxx'), headers: @headers, as: :json
    assert_response 400
    expected = { error: {
      type: "invalid_mentor_student_relationship",
      message: I18n.t('api.errors.invalid_mentor_student_relationship')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  # TODO: Check whether 400 is valid when the toggle_favorite fails
  # due to there not being a discussion between student and mentor

  test "delete should 200 if valid" do
    mentor = create :user
    student = create :user

    create :solution_mentor_discussion, mentor: mentor, solution: create(:concept_solution, user: student)

    setup_user(mentor)
    delete api_mentor_unfavorite_student_path(student_handle: student.handle), headers: @headers, as: :json
    assert_response 200

    assert Mentor::StudentRelationship.where(mentor: mentor, student: student, favorite: false).exists?
  end
end
