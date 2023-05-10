require_relative "../react_component_test_case"

class ReactComponents::Student::MentoringSessionTest < ReactComponentTestCase
  test "mentoring solution renders with discussion" do
    mentor = create :user
    student = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, user: student, track:)
    discussion = create(:mentor_discussion, solution:, mentor:)
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)

    iteration_1 = create(:iteration, solution:)
    iteration_2 = create(:iteration, solution:)
    create :mentor_discussion_post, discussion:, iteration: iteration_2, seen_by_student: true

    iteration_3 = create(:iteration, solution:)
    create :mentor_discussion_post, discussion:, iteration: iteration_3, seen_by_student: true
    create :mentor_discussion_post, discussion:, iteration: iteration_3, seen_by_student: false

    component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, discussion)

    assert_component component,
      "student-mentoring-session",
      {
        user_handle: student.handle,
        request: SerializeMentorSessionRequest.(mentor_request, student),
        discussion: SerializeMentorDiscussionForStudent.(discussion),
        track: SerializeMentorSessionTrack.(track),
        exercise: SerializeMentorSessionExercise.(exercise),
        iterations: [
          SerializeIteration.(iteration_1).merge(unread: false),
          SerializeIteration.(iteration_2).merge(unread: false),
          SerializeIteration.(iteration_3).merge(unread: true)
        ],
        mentor: {
          name: mentor.name,
          handle: mentor.handle,
          flair: mentor&.flair,
          bio: mentor.bio,
          languages_spoken: mentor.languages_spoken,
          avatar_url: mentor.avatar_url,
          reputation: mentor.formatted_reputation,
          num_discussions: 0
        },
        track_objectives: "",
        out_of_date: false,
        videos: [],
        links: {
          exercise: Exercism::Routes.track_exercise_mentor_discussions_url(track, exercise),
          create_mentor_request: Exercism::Routes.api_solution_mentor_requests_path(solution.uuid),
          learn_more_about_private_mentoring: Exercism::Routes.doc_path(:using, "feedback/private"),
          private_mentoring: solution.external_mentoring_request_url,
          mentoring_guide: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored")
        }
      }
  end

  test "mentoring solution renders with request" do
    student = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, user: student, track:)
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)

    iteration = create(:iteration, solution:)

    component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, nil)

    assert_component component,
      "student-mentoring-session",
      {
        user_handle: student.handle,
        request: SerializeMentorSessionRequest.(mentor_request, student),
        discussion: nil,
        track: SerializeMentorSessionTrack.(track),
        exercise: SerializeMentorSessionExercise.(exercise),
        iterations: [
          SerializeIteration.(iteration).merge(unread: false)
        ],
        mentor: nil,
        track_objectives: "",
        out_of_date: false,
        videos: [
          {
            url: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored"),
            thumb: "https://exercism-static.s3.eu-west-1.amazonaws.com/blog/tutorial-making-the-most-of-being-mentored.png",
            title: "Making the most of being mentored",
            date: Date.new(2021, 9, 1).iso8601
          }
        ],
        links: {
          exercise: Exercism::Routes.track_exercise_mentor_discussions_url(track, exercise),
          create_mentor_request: Exercism::Routes.api_solution_mentor_requests_path(solution.uuid),
          learn_more_about_private_mentoring: Exercism::Routes.doc_path(:using, "feedback/private"),
          private_mentoring: solution.external_mentoring_request_url,
          mentoring_guide: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored")
        }
      }
  end
end
