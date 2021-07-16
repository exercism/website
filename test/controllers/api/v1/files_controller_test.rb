require_relative '../base_test_case'

class API::V1::FilesControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_v1_solution_file_path, args: 2

  test "show should return 404 when solution is missing" do
    setup_user
    get api_v1_solution_file_path(999, "foobar"), headers: @headers, as: :json
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

    get api_v1_solution_file_path(solution.uuid, "missing.rb"), headers: @headers, as: :json

    assert_response 404
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
    assert_response :success
  end

  test "show should return solution file" do
    setup_user
    solution = create :practice_solution, user: @current_user
    submission = create :submission, solution: solution
    content = "foobar!!"
    file = create :submission_file, submission: submission, content: content

    get "/api/v1/solutions/#{solution.uuid}/files/#{file.filename}", headers: @headers, as: :json
    assert_response 200
    assert_equal response.body, content
  end

  test "show should return special README.md solution file" do
    setup_user
    solution = create :practice_solution, user: @current_user
    create :submission, solution: solution
    content = "# Bob\n\nWelcome to Bob on Exercism's Ruby Track.\nIf you need help running the tests or submitting your code, check out `HELP.md`.\nIf you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)\n\n## Introduction\n\nIntroduction for bob\n\nExtra introduction for bob\n\n## Instructions\n\nInstructions for bob\n\nExtra instructions for bob\n\n## Source\n\n### Created by\n\n- @erikschierboom\n\n### Contributed to by\n\n- @ihid\n\n### Based on\n\nInspired by the 'Deaf Grandma' exercise in Chris Pine's Learn to Program tutorial. - http://pine.fm/LearnToProgram/?Chapter=06" # rubocop:disable Layout/LineLength

    get "/api/v1/solutions/#{solution.uuid}/files/README.md", headers: @headers, as: :json
    assert_response 200
    assert_includes response.body, content
  end

  test "show should return special HELP.md solution file" do
    setup_user
    solution = create :practice_solution, user: @current_user
    create :submission, solution: solution
    content = "# Help\n\n## Running the tests\n\nRun the tests using `ruby test`.\n\n## Submitting your solution\n\nYou can submit your solution using the `exercism submit bob.rb` command.\nThis command will upload your solution to the Exercism website and print the solution page's URL.\n\nIt's possible to submit an incomplete solution which allows you to:\n\n- See how others have completed the exercise\n- Request help from a mentor\n\n## Need to get help?\n\nIf you'd like help solving the exercise, check the following pages:\n\n- [Installing Ruby locally](https://exercism.io/docs/tracks/ruby/installation/)\n- [How to learn Ruby](https://exercism.io/docs/tracks/ruby/learning/)\n- [Useful Ruby resources](https://exercism.io/docs/tracks/ruby/resources/)\n- [Testing on the Ruby track](https://exercism.io/docs/tracks/ruby/tests/)\n\nFor more general, non-track specific help, check:\n\n- [Exercism's support channel on gitter](https://gitter.im/exercism/support)\n- The [Frequently Asked Questions](https://exercism.io/docs/faq) TODO: (Required) use correct link\n\nShould those resources not suffice, you could submit your (incomplete) solution to request mentoring.\n\nStuck? Try the Ruby gitter channel." # rubocop:disable Layout/LineLength

    get "/api/v1/solutions/#{solution.uuid}/files/HELP.md", headers: @headers, as: :json
    assert_response 200
    assert_equal response.body, content
  end

  test "show should return special HINTS.md solution file" do
    setup_user
    solution = create :practice_solution, user: @current_user
    create :submission, solution: solution
    content = "# Hints\n\n## General\n\n- There are many useful string methods built-in"

    get "/api/v1/solutions/#{solution.uuid}/files/HINTS.md", headers: @headers, as: :json
    assert_response 200
    assert_equal response.body, content
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
  #   assert_response :success
  # end

  # test "show should return 200 if solution is published" do
  #   skip
  #   setup_user
  #   exercise = create :concept_exercise
  #   track = exercise.track
  #   solution = create :concept_solution, exercise: exercise, published_at: DateTime.yesterday
  #
  #   get api_v1_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
  #   assert_response :success
  # end

  # test "show should return 403 for a normal user when the solution is not published" do
  #   skip
  #   setup_user
  #   exercise = create :concept_exercise
  #   track = exercise.track
  #   solution = create :concept_solution, exercise: exercise
  #
  #   get api_v1_solution_file_path(solution.uuid, "bob.rb"), headers: @headers, as: :json
  #   assert_response 403
  # end
end
