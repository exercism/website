require_relative '../base_test_case'

class API::Submissions::FilesControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_submission_files_path, args: 1

  ###
  # INDEX
  ###

  test "index should return 404 when submission doesnt exist" do
    setup_user

    get api_submission_files_path(1),
      headers: @headers,
      as: :json

    assert_response 404
    expected = { error: {
      type: "submission_not_found",
      message: I18n.t('api.errors.submission_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "index should return 404 when submission is inaccessible" do
    setup_user
    submission = create :submission

    get api_submission_files_path(submission),
      headers: @headers,
      as: :json

    assert_response 403
    expected = { error: {
      type: "submission_not_accessible",
      message: I18n.t('api.errors.submission_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "index should return files" do
    mentor = create :user
    setup_user(mentor)
    solution = create :concept_solution
    create :solution_mentor_discussion, solution: solution, mentor: mentor
    submission = create :submission, solution: solution
    create :submission_file, filename: "bob.rb", content: "class Bob", submission: submission

    get api_submission_files_path(submission),
      headers: @headers,
      as: :json

    assert_response 200
    expected = {
      files: [
        {
          filename: "bob.rb",
          content: "class Bob"
        }
      ]
    }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
end
