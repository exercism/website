require_relative "../react_component_test_case"

module Mentoring
  class DiscussionTest < ReactComponentTestCase
    test "mentoring discussion renders correctly" do
      mentor = create :user
      student = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, user: student, track: track
      discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor

      iteration_1 = create :iteration, solution: solution
      iteration_2 = create :iteration, solution: solution
      create :solution_mentor_discussion_post, discussion: discussion, iteration: iteration_2, seen_by_mentor: true

      iteration_3 = create :iteration, solution: solution
      create :solution_mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_mentor: true
      create :solution_mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_mentor: false

      component = ReactComponents::Mentoring::Discussion.new(discussion)
      component.stubs(current_user: student)
      scratchpad = ScratchpadPage.new(about: exercise)

      assert_component component,
        "mentoring-discussion",
        {
          discussion_id: discussion.uuid,
          user_id: student.id,
          student: {
            name: student.name,
            handle: student.handle,
            bio: student.bio,
            languages_spoken: student.languages_spoken,
            avatar_url: student.avatar_url,
            reputation: student.reputation,
            is_favorite: false,
            num_previous_sessions: 15,
            links: {
              favorite: Exercism::Routes.api_mentor_favorite_student_path(student_handle: student.handle)
            }
          },
          track: {
            title: track.title,
            highlightjs_language: track.highlightjs_language,
            icon_url: track.icon_url
          },
          exercise: {
            title: exercise.title
          },
          iterations: [
            {
              uuid: iteration_1.uuid,
              idx: iteration_1.idx,
              num_comments: 0,
              unread: false,
              created_at: iteration_1.created_at.iso8601,
              tests_status: iteration_1.tests_status,
              automated_feedback: iteration_1.automated_feedback,
              links: {
                files: Exercism::Routes.api_submission_files_url(iteration_1.submission)
              }
            },
            {
              uuid: iteration_2.uuid,
              idx: iteration_2.idx,
              num_comments: 1,
              unread: false,
              created_at: iteration_2.created_at.iso8601,
              tests_status: iteration_2.tests_status,
              automated_feedback: iteration_2.automated_feedback,
              links: {
                files: Exercism::Routes.api_submission_files_url(iteration_2.submission)
              }
            },
            {
              uuid: iteration_3.uuid,
              idx: iteration_3.idx,
              num_comments: 2,
              unread: true,
              created_at: iteration_3.created_at.iso8601,
              tests_status: iteration_3.tests_status,
              automated_feedback: iteration_3.automated_feedback,
              links: {
                files: Exercism::Routes.api_submission_files_url(iteration_3.submission)
              }
            }
          ],
          mentor_solution: nil,
          notes: %{<h3>Talking points</h3>\n<ul>\n  <li>\n    <code>each_cons</code> instead of an iterator\n    <code>with_index</code>: In Ruby, you rarely have to write\n    iterators that need to keep track of the index. Enumerable has\n    powerful methods that do that for us.\n  </li>\n  <li>\n    <code>chars</code>: instead of <code>split("")</code>.\n  </li>\n</ul>}, # rubocop:disable Layout/LineLength
          links: {
            mentor_dashboard: Exercism::Routes.mentor_dashboard_path,
            exercise: Exercism::Routes.track_exercise_path(track, exercise),
            scratchpad: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title),
            posts: Exercism::Routes.api_mentor_discussion_posts_url(discussion),
            finish: Exercism::Routes.finish_api_mentor_discussion_path(discussion)
          }
        }
    end

    test "#links adds link to mark as nothing to do when discussion requires mentor action" do
      discussion = create :solution_mentor_discussion, requires_mentor_action_since: 2.days.ago

      component = ReactComponents::Mentoring::Discussion.new(discussion)

      assert_equal Exercism::Routes.mark_as_nothing_to_do_api_mentor_discussion_path(discussion),
        component.links[:mark_as_nothing_to_do]
    end

    test "#links adds link to finish discussion when discussion is finishd" do
      discussion = create :solution_mentor_discussion, finishd_at: nil
      comp = ReactComponents::Mentoring::Discussion.new(discussion)
      assert_equal Exercism::Routes.finish_api_mentor_discussion_path(discussion), comp.links[:finish]

      discussion.update(finishd_at: Time.current)
      comp = ReactComponents::Mentoring::Discussion.new(discussion)
      assert_nil comp.links[:finish]
    end
  end
end
