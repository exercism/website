require_relative '../base_test_case'

class API::V1::FilesControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_v1_solution_file_path, args: 2

  test "show should return 404 when solution is missing" do
    setup_user
    get api_v1_solution_file_path(999, "foobar"), headers: @headers, as: :json
    assert_response :not_found
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

    get api_v1_solution_file_path(solution.uuid, "missing.rb"), headers: @headers, as: :json

    assert_response :not_found
    expected = { error: {
      type: "file_not_found",
      message: I18n.t('api.errors.file_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "show should return 404 for different user if all iterations are deleted" do
    setup_user
    solution = create :practice_solution, :published

    filename = "meh"
    old_submission = create(:submission, solution:)
    create :submission_file, submission: old_submission, filename:, content: "old-code"

    deleted_iteration_submission = create(:submission, solution:)
    create :submission_file, submission: deleted_iteration_submission, filename:, content: "deleted-code"
    create :iteration, solution:, submission: deleted_iteration_submission, deleted_at: Time.current

    second_deleted_iteration_submission = create(:submission, solution:)
    create :submission_file, submission: second_deleted_iteration_submission, filename:, content: "more-deleted-code"
    create :iteration, solution:, submission: second_deleted_iteration_submission, deleted_at: Time.current

    new_submission = create(:submission, solution:)
    create :submission_file, submission: new_submission, filename:, content: "new-code"

    get "/api/v1/solutions/#{solution.uuid}/files/#{filename}", headers: @headers, as: :json
    assert_response :not_found
    expected = { error: {
      type: "file_not_found",
      message: I18n.t('api.errors.file_not_found')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "show should return exercise file" do
    setup_user
    solution = create :practice_solution, user: @current_user

    get api_v1_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
    assert_response :ok
  end

  test "show should return solution file" do
    setup_user
    solution = create :practice_solution, user: @current_user
    submission = create(:submission, solution:)
    content = "foobar!!"
    file = create(:submission_file, submission:, content:)

    get "/api/v1/solutions/#{solution.uuid}/files/#{file.filename}", headers: @headers, as: :json
    assert_response :ok
    assert_equal response.body, content
  end

  test "show should return latest submission, not latest iteration for user" do
    setup_user
    solution = create :practice_solution, user: @current_user

    filename = "meh"
    old_submission = create(:submission, solution:)
    create :submission_file, submission: old_submission, filename:, content: "old-code"

    iteration_submission = create(:submission, solution:)
    create :submission_file, submission: iteration_submission, filename:, content: "iteration-code"
    create :iteration, solution:, submission: iteration_submission

    correct_content = "new-code"
    new_submission = create(:submission, solution:)
    create :submission_file, submission: new_submission, filename:, content: correct_content

    get "/api/v1/solutions/#{solution.uuid}/files/#{filename}", headers: @headers, as: :json
    assert_response :ok
    assert_equal correct_content, response.body
  end

  test "show should return latest iteration, not latest submission for different user" do
    setup_user
    solution = create :practice_solution, :published

    filename = "meh"
    old_submission = create(:submission, solution:)
    create :submission_file, submission: old_submission, filename:, content: "old-code"

    correct_content = "iteration-code"
    iteration_submission = create(:submission, solution:)
    create :submission_file, submission: iteration_submission, filename:, content: correct_content
    create :iteration, solution:, submission: iteration_submission

    deleted_iteration_submission = create(:submission, solution:)
    create :submission_file, submission: deleted_iteration_submission, filename:, content: "deleted-code"
    create :iteration, solution:, submission: deleted_iteration_submission, deleted_at: Time.current

    new_submission = create(:submission, solution:)
    create :submission_file, submission: new_submission, filename:, content: "new-code"

    get "/api/v1/solutions/#{solution.uuid}/files/#{filename}", headers: @headers, as: :json
    assert_response :ok
    assert_equal correct_content, response.body
  end

  test "show should return special README.md solution file" do
    setup_user
    solution = create :practice_solution, user: @current_user
    submission = create(:submission, solution:)
    create(:iteration, solution:, submission:)

    get "/api/v1/solutions/#{solution.uuid}/files/README.md", headers: @headers, as: :json
    assert_response :ok

    expected_body = <<~EXPECTED.strip
      # Bob

      Welcome to Bob on Exercism's Ruby Track.
      If you need help running the tests or submitting your code, check out `HELP.md`.
      If you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)

      ## Introduction

      Introduction for bob

      Extra introduction for bob

      ## Instructions

      Instructions for bob

      Extra instructions for bob

      ## Source

      ### Created by

      - @erikschierboom

      ### Contributed to by

      - @ihid

      ### Based on

      Inspired by the 'Deaf Grandma' exercise in Chris Pine's Learn to Program tutorial. - http://pine.fm/LearnToProgram/?Chapter=06
    EXPECTED
    assert_includes response.body, expected_body
  end

  test "show should return special HELP.md solution file" do
    setup_user
    solution = create :practice_solution, user: @current_user
    submission = create(:submission, solution:)
    create(:iteration, solution:, submission:)

    get "/api/v1/solutions/#{solution.uuid}/files/HELP.md", headers: @headers, as: :json
    assert_response :ok

    expected_body = <<~EXPECTED.strip
      # Help

      ## Running the tests

      Run the tests using `ruby test`.

      ## Submitting your solution

      You can submit your solution using the `exercism submit bob.rb` command.
      This command will upload your solution to the Exercism website and print the solution page's URL.

      It's possible to submit an incomplete solution which allows you to:

      - See how others have completed the exercise
      - Request help from a mentor

      ## Need to get help?

      If you'd like help solving the exercise, check the following pages:

      - The [Ruby track's documentation](https://exercism.org/docs/tracks/ruby)
      - The [Ruby track's programming category on the forum](https://forum.exercism.org/c/programming/ruby)
      - [Exercism's programming category on the forum](https://forum.exercism.org/c/programming/5)
      - The [Frequently Asked Questions](https://exercism.org/docs/using/faqs)

      Should those resources not suffice, you could submit your (incomplete) solution to request mentoring.

      Stuck? Try the Ruby gitter channel.
    EXPECTED
    assert_equal response.body, expected_body
  end

  test "show should return special HINTS.md solution file" do
    setup_user
    solution = create :practice_solution, user: @current_user
    submission = create(:submission, solution:)
    create(:iteration, solution:, submission:)

    get "/api/v1/solutions/#{solution.uuid}/files/HINTS.md", headers: @headers, as: :json
    assert_response :ok

    expected_body = <<~EXPECTED.strip
      # Hints

      ## General

      - There are many useful string methods built-in
    EXPECTED
    assert_equal response.body, expected_body
  end

  # test "show should return 200 if user is mentor" do
  #   skip
  #   setup_user
  #   exercise = create :concept_exercise
  #   track = exercise.track
  #   create :track_mentorship, user: @current_user, track: track
  #   solution = create :concept_solution, exercise: exercise
  #
  #   get api_v1_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
  #   assert_response :ok
  # end

  # test "show should return 200 if solution is published" do
  #   skip
  #   setup_user
  #   exercise = create :concept_exercise
  #   track = exercise.track
  #   solution = create :concept_solution, exercise: exercise, published_at: DateTime.yesterday
  #
  #   get api_v1_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
  #   assert_response :ok
  # end

  # test "show should return 403 for a normal user when the solution is not published" do
  #   skip
  #   setup_user
  #   exercise = create :concept_exercise
  #   track = exercise.track
  #   solution = create :concept_solution, exercise: exercise
  #
  #   get api_v1_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
  #   assert_response :forbidden
  # end
end
