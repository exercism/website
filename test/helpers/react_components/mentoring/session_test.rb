require_relative "../react_component_test_case"

class ReactComponents::Mentoring::SessionTest < ReactComponentTestCase
  test "mentoring request renders correctly" do
    TestHelpers.use_website_copy_test_repo!

    mentor = create :user
    student = create :user
    track = create :track, slug: "ruby"
    user_track = create :user_track, track:, user: student
    exercise = create :concept_exercise, track:, slug: "lasagna"
    solution = create(:concept_solution, user: student, exercise:)
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)

    iteration_1 = create(:iteration, solution:)
    iteration_2 = create(:iteration, solution:)
    iteration_3 = create(:iteration, solution:)

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
        instructions: Markdown::Parse.(solution.instructions),
        test_files: SerializeFiles.(solution.test_files),
        student: SerializeStudent.(student, mentor, relationship: nil, anonymous_mode: false, user_track:),
        student_solution_uuid: solution.uuid,
        mentor_solution: nil,
        exemplar_files: Session::SerializeExemplarFiles.(exercise.exemplar_files),
        guidance: {
          exercise: exercise.mentoring_notes_content,
          track: track.mentoring_notes_content,
          links: {
            improve_exercise_guidance: exercise.mentoring_notes_edit_url,
            improve_track_guidance: track.mentoring_notes_edit_url
          }
        },
        out_of_date: false,
        download_command: solution.mentor_download_cmd,
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
          mentor_queue: Exercism::Routes.mentoring_queue_path,
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
    user_track = create(:user_track, user: student, track:)
    exercise = create :concept_exercise, track:, slug: "lasagna"
    solution = create(:concept_solution, user: student, exercise:)
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)
    discussion = create :mentor_discussion, solution:, mentor:, request: mentor_request

    iteration_1 = create(:iteration, solution:)
    iteration_2 = create(:iteration, solution:)
    create :mentor_discussion_post, discussion:, iteration: iteration_2, seen_by_mentor: true

    iteration_3 = create(:iteration, solution:)
    create :mentor_discussion_post, discussion:, iteration: iteration_3, seen_by_mentor: true
    create :mentor_discussion_post, discussion:, iteration: iteration_3, seen_by_mentor: false

    component = ReactComponents::Mentoring::Session.new(discussion:)
    component.stubs(current_user: mentor)
    scratchpad = ScratchpadPage.new(about: exercise)

    assert_component(
      render(component),
      "mentoring-session",
      {
        user_handle: mentor.handle,
        request: SerializeMentorSessionRequest.(mentor_request, mentor),
        discussion: SerializeMentorDiscussionForMentor.(discussion, relationship: nil),
        track: SerializeMentorSessionTrack.(track),
        exercise: SerializeMentorSessionExercise.(exercise),
        iterations: [
          SerializeIteration.(iteration_1).merge(unread: false),
          SerializeIteration.(iteration_2).merge(unread: false),
          SerializeIteration.(iteration_3).merge(unread: true)
        ],
        instructions: Markdown::Parse.(solution.instructions),
        test_files: SerializeFiles.(solution.test_files),
        student: SerializeStudent.(student, mentor, relationship: nil, anonymous_mode: false, user_track:, discussion:),
        student_solution_uuid: solution.uuid,
        mentor_solution: nil,
        exemplar_files: [
          {
            filename: "exemplar.rb",
            content: exercise.exemplar_files.values.first
          }
        ],
        guidance: {
          exercise: exercise.mentoring_notes_content,
          track: track.mentoring_notes_content,
          links: {
            improve_exercise_guidance: exercise.mentoring_notes_edit_url,
            improve_track_guidance: track.mentoring_notes_edit_url
          }
        },
        out_of_date: false,
        download_command: solution.mentor_download_cmd,
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
          mentor_queue: Exercism::Routes.mentoring_queue_path,
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
    user_track = create :user_track, track:, user: student
    exercise = create :concept_exercise, track:, slug: "lasagna"
    solution = create(:concept_solution, user: student, exercise:)
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)

    iteration_1 = create(:iteration, solution:)
    iteration_2 = create(:iteration, solution:)
    iteration_3 = create(:iteration, solution:)

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
        instructions: Markdown::Parse.(solution.instructions),
        test_files: SerializeFiles.(solution.test_files),
        student: SerializeStudent.(student, mentor, relationship: nil, anonymous_mode: false, user_track:),
        student_solution_uuid: solution.uuid,
        mentor_solution: nil,
        exemplar_files: Session::SerializeExemplarFiles.(exercise.exemplar_files),
        guidance: {
          exercise: exercise.mentoring_notes_content,
          track: track.mentoring_notes_content,
          links: {
            improve_exercise_guidance: exercise.mentoring_notes_edit_url,
            improve_track_guidance: track.mentoring_notes_edit_url
          }
        },
        out_of_date: false,
        download_command: solution.mentor_download_cmd,
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
          mentor_queue: Exercism::Routes.mentoring_queue_path,
          exercise: Exercism::Routes.track_exercise_path(track, exercise),
          mentoring_docs: Exercism::Routes.docs_section_path(:mentoring)
        }
      }
    )
  end

  test "exemplar files are serialized correctly" do
    files = {
      ".meta/exemplar1.rb" => "class Ruby\nend"
    }

    assert_equal(
      [
        {
          filename: "exemplar1.rb",
          content: "class Ruby\nend"
        }
      ],
      Session::SerializeExemplarFiles.(files)
    )
  end
end
