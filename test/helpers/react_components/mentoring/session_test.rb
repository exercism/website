require_relative "../react_component_test_case"

module Mentoring
  class SessionTest < ReactComponentTestCase
    test "mentoring solution renders correctly" do
      TestHelpers.use_website_copy_test_repo!

      mentor = create :user
      student = create :user
      track = create :track, slug: "ruby"
      exercise = create :concept_exercise, track: track, slug: "clock"
      solution = create :concept_solution, user: student, exercise: exercise
      discussion = create :mentor_discussion, solution: solution, mentor: mentor
      mentor_request = create :mentor_request,
        solution: solution,
        comment_markdown: "Hello",
        updated_at: Time.utc(2016, 12, 25)

      iteration_1 = create :iteration, solution: solution
      iteration_2 = create :iteration, solution: solution
      create :mentor_discussion_post, discussion: discussion, iteration: iteration_2, seen_by_mentor: true

      iteration_3 = create :iteration, solution: solution
      create :mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_mentor: true
      create :mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_mentor: false

      component = ReactComponents::Mentoring::Session.new(solution)
      component.stubs(current_user: mentor)
      scratchpad = ScratchpadPage.new(about: exercise)

      assert_component component,
        "mentoring-session",
        {
          user_id: mentor.id,
          request: SerializeMentorSessionRequest.(mentor_request),
          discussion: SerializeMentorDiscussion.(discussion, :mentor),
          track: SerializeMentorSessionTrack.(track),
          exercise: SerializeMentorSessionExercise.(exercise),
          iterations: [
            SerializeIteration.(iteration_1).merge(num_comments: 0, unread: false),
            SerializeIteration.(iteration_2).merge(num_comments: 1, unread: false),
            SerializeIteration.(iteration_3).merge(num_comments: 2, unread: true)
          ],
          student: SerializeStudent.(student, relationship: nil, anonymous_mode: false),
          mentor_solution: nil,
          notes: %(<p>Clock introduces students to the concept of value objects and modular arithmetic.</p>\n<p>Note: This exercise changes a lot depending on which version the person has solved.</p>\n), # rubocop:disable Layout/LineLength
          links: {
            mentor_dashboard: Exercism::Routes.mentoring_inbox_path,
            exercise: Exercism::Routes.track_exercise_path(track, exercise),
            scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
          }
        }
    end
  end
end
