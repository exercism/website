require_relative "../react_component_test_case"

module Mentoring::Student
  class MentoringSessionTest < ReactComponentTestCase
    test "mentoring solution renders correctly" do
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
          user_id: student.id,
          request: SerializeMentorSessionRequest.(mentor_request),
          discussion: SerializeMentorSessionDiscussion.(discussion, student),
          track: SerializeMentorSessionTrack.(track),
          exercise: SerializeMentorSessionExercise.(exercise),
          iterations: [

            SerializeIteration.(iteration_1).merge(num_comments: 0, unread: false),
            SerializeIteration.(iteration_2).merge(num_comments: 1, unread: false),
            SerializeIteration.(iteration_3).merge(num_comments: 2, unread: true)
          ],
          mentor: {
            id: mentor.id,
            name: mentor.name,
            handle: mentor.handle,
            bio: mentor.bio,
            languages_spoken: mentor.languages_spoken,
            avatar_url: mentor.avatar_url,
            reputation: mentor.formatted_reputation,
            num_previous_sessions: 15
          },
          is_first_time_on_track: true,
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
            exercise: Exercism::Routes.track_exercise_url(track, exercise),
            create_mentor_request: Exercism::Routes.api_solution_mentor_request_path(solution.uuid),
            learn_more_about_private_mentoring: "#",
            private_mentoring: "https://some.link/we/need/to-decide-on",
            mentoring_guide: "#"
          }
        }
    end
  end
end
