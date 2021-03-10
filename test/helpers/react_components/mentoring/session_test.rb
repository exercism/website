require_relative "../react_component_test_case"

module Mentoring
  class SessionTest < ReactComponentTestCase
    test "mentoring solution renders correctly" do
      mentor = create :user
      student = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, user: student, track: track
      discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
      mentor_request = create :solution_mentor_request,
        solution: solution,
        comment_markdown: "Hello",
        updated_at: Time.utc(2016, 12, 25)

      iteration_1 = create :iteration, solution: solution
      iteration_2 = create :iteration, solution: solution
      create :solution_mentor_discussion_post, discussion: discussion, iteration: iteration_2, seen_by_mentor: true

      iteration_3 = create :iteration, solution: solution
      create :solution_mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_mentor: true
      create :solution_mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_mentor: false

      component = ReactComponents::Mentoring::Session.new(solution)
      component.stubs(current_user: mentor)
      scratchpad = ScratchpadPage.new(about: exercise)

      assert_component component,
        "mentoring-session",
        {
          user_id: mentor.id,
          relationship: nil,
          request: SerializeMentorSessionRequest.(mentor_request),
          discussion: SerializeMentorSessionDiscussion.(discussion, mentor),
          track: SerializeMentorSessionTrack.(track),
          exercise: SerializeMentorSessionExercise.(exercise),
          iterations: [

            SerializeIteration.(iteration_1).merge(num_comments: 0, unread: false),
            SerializeIteration.(iteration_2).merge(num_comments: 1, unread: false),
            SerializeIteration.(iteration_3).merge(num_comments: 2, unread: true)
          ],
          student: {
            id: student.id,
            name: student.name,
            handle: student.handle,
            bio: student.bio,
            languages_spoken: student.languages_spoken,
            avatar_url: student.avatar_url,
            reputation: student.reputation,
            is_favorite: false,
            num_previous_sessions: 15,
            links: {
              favorite: Exercism::Routes.favorite_api_mentoring_student_path(student.handle)
            }
          },

          mentor_solution: nil,
          notes: %{<h3>Talking points</h3>\n<ul>\n  <li>\n    <code>each_cons</code> instead of an iterator\n    <code>with_index</code>: In Ruby, you rarely have to write\n    iterators that need to keep track of the index. Enumerable has\n    powerful methods that do that for us.\n  </li>\n  <li>\n    <code>chars</code>: instead of <code>split("")</code>.\n  </li>\n</ul>}, # rubocop:disable Layout/LineLength
          links: {
            mentor_dashboard: Exercism::Routes.mentoring_dashboard_path,
            exercise: Exercism::Routes.track_exercise_path(track, exercise),
            scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
          }
        }
    end
  end
end
