require_relative '../../base_test_case'

class API::Mentoring::Discussions::PreviousSessionsControllerTest < API::BaseTestCase
  ###
  # Index
  ###
  test "index does not return previous discussions from other students" do
    mentor = create :user
    student = create :user

    lasagna = create :concept_exercise, slug: "lasagna"
    solution = create :concept_solution, exercise: lasagna, user: student
    lasagna_discussion = create :mentor_discussion, :finished, solution: solution, mentor: mentor
    submission = create :submission, solution: solution
    create :iteration, submission: submission

    walking = create :concept_exercise, slug: "walking"
    solution = create :concept_solution, exercise: walking
    create :mentor_discussion, solution: solution, mentor: mentor
    submission = create :submission, solution: solution
    create :iteration, submission: submission

    setup_user(mentor)
    get api_mentoring_discussion_previous_sessions_path(lasagna_discussion), headers: @headers, as: :json

    assert_response 200
    expected = {
      results: [],
      meta: {
        current_page: 1,
        total_count: 0,
        total_pages: 0
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end
end
