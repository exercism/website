require_relative './base_test_case'

class API::FilesControllerTest < API::BaseTestCase
  test "show should return 401 with incorrect token" do
    get api_solution_file_path(1, "foobar"), as: :json
    assert_response 401
  end

  test "show should return 404 when solution is missing" do
    setup_user
    get api_solution_file_path(999, "foobar"), headers: @headers, as: :json
    assert_response 404
    expected = { error: {
      type: "solution_not_found",
      message: I18n.t('api.errors.solution_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "show should return 404 when file is missing" do
    setup_user
    solution = create :concept_solution, user: @current_user

    get api_solution_file_path(solution.uuid, "missing.rb"), headers: @headers, as: :json

    assert_response 404
    expected = { error: {
      type: "file_not_found",
      message: I18n.t('api.errors.file_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "show should return exercise file" do
    Git::Exercise.any_instance.expects(:file).with("bob.rb").returns("some content")

    setup_user
    solution = create :concept_solution, user: @current_user

    get api_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
    assert_response :success
  end

  test "show should return solution file" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create :submission, solution: solution
    content = "foobar!!"
    file = create :submission_file, submission: submission, content: content

    get "/api/v1/solutions/#{solution.uuid}/files/#{file.filename}", headers: @headers, as: :json
    assert_response 200
    assert content, response.body
  end

  # test "show should return 200 if user is mentor" do
  #   skip
  #   setup_user
  #   exercise = create :concept_exercise
  #   track = exercise.track
  #   create :track_mentorship, user: @current_user, track: track
  #   solution = create :concept_solution, exercise: exercise
  #
  #   get api_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
  #   assert_response :success
  # end

  # test "show should return 200 if solution is published" do
  #   skip
  #   setup_user
  #   exercise = create :concept_exercise
  #   track = exercise.track
  #   solution = create :concept_solution, exercise: exercise, published_at: DateTime.yesterday
  #
  #   get api_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
  #   assert_response :success
  # end

  # test "show should return 403 for a normal user when the solution is not published" do
  #   skip
  #   setup_user
  #   exercise = create :concept_exercise
  #   track = exercise.track
  #   solution = create :concept_solution, exercise: exercise
  #
  #   get api_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
  #   assert_response 403
  # end
end
