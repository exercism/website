require_relative "../react_component_test_case"

module Mentoring
  class SessionTest < ReactComponentTestCase
    test "mentoring request renders correctly" do
      TestHelpers.use_website_copy_test_repo!

      mentor = create :user
      student = create :user
      track = create :track, slug: "ruby"
      user_track = create :user_track, track: track, user: student
      exercise = create :concept_exercise, track: track, slug: "clock"
      solution = create :concept_solution, user: student, exercise: exercise
      mentor_request = create :mentor_request,
        solution: solution,
        comment_markdown: "Hello",
        updated_at: Time.utc(2016, 12, 25)

      iteration_1 = create :iteration, solution: solution
      iteration_2 = create :iteration, solution: solution
      iteration_3 = create :iteration, solution: solution

      component = ReactComponents::Mentoring::Session.new(request: mentor_request)
      component.stubs(current_user: mentor)
      scratchpad = ScratchpadPage.new(about: exercise)

      assert_component(
        render(component),
        "mentoring-session",
        {
          user_handle: mentor.handle,
          request: SerializeMentorSessionRequest.(mentor_request, mentor),
          discussion: nil,
          track: SerializeMentorSessionTrack.(track),
          exercise: SerializeMentorSessionExercise.(exercise),
          iterations: [
            SerializeIteration.(iteration_1).merge(unread: false),
            SerializeIteration.(iteration_2).merge(unread: false),
            SerializeIteration.(iteration_3).merge(unread: false)
          ],
          student: SerializeStudent.(student, mentor, relationship: nil, anonymous_mode: false, user_track: user_track),
          mentor_solution: nil,
          notes: %(<p>Clock introduces students to the concept of value objects and modular arithmetic.</p>\n<p>Note: This exercise changes a lot depending on which version the person has solved.</p>\n), # rubocop:disable Layout/LineLength
          out_of_date: false,
          scratchpad: {
            is_introducer_hidden: false,
            links: {
              markdown: Exercism::Routes.doc_url(:mentoring, "markdown"),
              hide_introducer: Exercism::Routes.hide_api_settings_introducer_path("scratchpad"),
              self: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
            }
          },
          links: {
            mentor_dashboard: Exercism::Routes.mentoring_inbox_path,
            exercise: Exercism::Routes.track_exercise_path(track, exercise),
            mentoring_docs: Exercism::Routes.docs_section_path(:mentoring)
          }
        }
      )
    end

    test "mentoring discussion renders correctly" do
      TestHelpers.use_website_copy_test_repo!

      mentor = create :user
      student = create :user
      track = create :track, slug: "ruby"
      user_track = create :user_track, user: student, track: track
      exercise = create :concept_exercise, track: track, slug: "clock"
      solution = create :concept_solution, user: student, exercise: exercise
      mentor_request = create :mentor_request,
        solution: solution,
        comment_markdown: "Hello",
        updated_at: Time.utc(2016, 12, 25)
      discussion = create :mentor_discussion, solution: solution, mentor: mentor, request: mentor_request

      iteration_1 = create :iteration, solution: solution
      iteration_2 = create :iteration, solution: solution
      create :mentor_discussion_post, discussion: discussion, iteration: iteration_2, seen_by_mentor: true

      iteration_3 = create :iteration, solution: solution
      create :mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_mentor: true
      create :mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_mentor: false

      component = ReactComponents::Mentoring::Session.new(discussion: discussion)
      component.stubs(current_user: mentor)
      scratchpad = ScratchpadPage.new(about: exercise)

      assert_component(
        render(component),
        "mentoring-session",
        {
          user_handle: mentor.handle,
          request: SerializeMentorSessionRequest.(mentor_request, mentor),
          discussion: SerializeMentorDiscussion.(discussion, :mentor),
          track: SerializeMentorSessionTrack.(track),
          exercise: SerializeMentorSessionExercise.(exercise),
          iterations: [
            SerializeIteration.(iteration_1).merge(unread: false),
            SerializeIteration.(iteration_2).merge(unread: false),
            SerializeIteration.(iteration_3).merge(unread: true)
          ],
          student: SerializeStudent.(student, mentor, user_track: user_track, relationship: nil, anonymous_mode: false),
          mentor_solution: nil,
          notes: %(<p>Clock introduces students to the concept of value objects and modular arithmetic.</p>\n<p>Note: This exercise changes a lot depending on which version the person has solved.</p>\n), # rubocop:disable Layout/LineLength
          out_of_date: false,
          scratchpad: {
            is_introducer_hidden: false,
            links: {
              markdown: Exercism::Routes.doc_url(:mentoring, "markdown"),
              hide_introducer: Exercism::Routes.hide_api_settings_introducer_path("scratchpad"),
              self: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
            }
          },
          links: {
            mentor_dashboard: Exercism::Routes.mentoring_inbox_path,
            exercise: Exercism::Routes.track_exercise_path(track, exercise),
            mentoring_docs: Exercism::Routes.docs_section_path(:mentoring)
          }
        }
      )
    end

    test "hidden scratchpad introducer" do
      TestHelpers.use_website_copy_test_repo!

      mentor = create :user
      student = create :user
      track = create :track, slug: "ruby"
      user_track = create :user_track, track: track, user: student
      exercise = create :concept_exercise, track: track, slug: "clock"
      solution = create :concept_solution, user: student, exercise: exercise
      mentor_request = create :mentor_request,
        solution: solution,
        comment_markdown: "Hello",
        updated_at: Time.utc(2016, 12, 25)

      iteration_1 = create :iteration, solution: solution
      iteration_2 = create :iteration, solution: solution
      iteration_3 = create :iteration, solution: solution

      create :user_dismissed_introducer, slug: 'scratchpad', user: mentor

      component = ReactComponents::Mentoring::Session.new(request: mentor_request)
      component.stubs(current_user: mentor)
      scratchpad = ScratchpadPage.new(about: exercise)

      assert_component(
        render(component),
        "mentoring-session",
        {
          user_handle: mentor.handle,
          request: SerializeMentorSessionRequest.(mentor_request, mentor),
          discussion: nil,
          track: SerializeMentorSessionTrack.(track),
          exercise: SerializeMentorSessionExercise.(exercise),
          iterations: [
            SerializeIteration.(iteration_1).merge(unread: false),
            SerializeIteration.(iteration_2).merge(unread: false),
            SerializeIteration.(iteration_3).merge(unread: false)
          ],
          student: SerializeStudent.(student, mentor, relationship: nil, anonymous_mode: false, user_track: user_track),
          mentor_solution: nil,
          notes: %(<p>Clock introduces students to the concept of value objects and modular arithmetic.</p>\n<p>Note: This exercise changes a lot depending on which version the person has solved.</p>\n), # rubocop:disable Layout/LineLength
          out_of_date: false,
          scratchpad: {
            is_introducer_hidden: true,
            links: {
              markdown: Exercism::Routes.doc_url(:mentoring, "markdown"),
              hide_introducer: Exercism::Routes.hide_api_settings_introducer_path("scratchpad"),
              self: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
            }
          },
          links: {
            mentor_dashboard: Exercism::Routes.mentoring_inbox_path,
            exercise: Exercism::Routes.track_exercise_path(track, exercise),
            mentoring_docs: Exercism::Routes.docs_section_path(:mentoring)
          }
        }
      )
    end
  end
end
