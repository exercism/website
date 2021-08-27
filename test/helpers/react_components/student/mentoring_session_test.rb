require_relative "../react_component_test_case"

module ReactComponents::Student
  class MentoringSessionTest < ReactComponentTestCase
    test "mentoring solution renders with discussion" do
      mentor = create :user
      student = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, user: student, track: track
      discussion = create :mentor_discussion, solution: solution, mentor: mentor
      mentor_request = create :mentor_request,
        solution: solution,
        comment_markdown: "Hello",
        updated_at: Time.utc(2016, 12, 25)

      iteration_1 = create :iteration, solution: solution
      iteration_2 = create :iteration, solution: solution
      create :mentor_discussion_post, discussion: discussion, iteration: iteration_2, seen_by_student: true

      iteration_3 = create :iteration, solution: solution
      create :mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_student: true
      create :mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_student: false

      component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, discussion)

      assert_component component,
        "student-mentoring-session",
        {
          user_handle: student.handle,
          request: SerializeMentorSessionRequest.(mentor_request, student),
          discussion: SerializeMentorDiscussion.(discussion, :student),
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
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, user: student, track: track
      mentor_request = create :mentor_request,
        solution: solution,
        comment_markdown: "Hello",
        updated_at: Time.utc(2016, 12, 25)

      iteration = create :iteration, solution: solution

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
              url: "#",
              title: "Start mentoring on Exercism..",
              date: Date.new(2020, 1, 24).iso8601
            },
            {
              url: "#",
              title: "Best practices writing feedback trrrrrruuuuunnnncaaatteeee",
              date: Date.new(2020, 1, 24).iso8601
            },
            {
              url: "#",
              title: "Beginners’ Guide to Mentoring",
              date: Date.new(2020, 1, 24).iso8601
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
end
