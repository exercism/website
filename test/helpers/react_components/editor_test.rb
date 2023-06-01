require_relative "./react_component_test_case"

class ReactComponents::EditorTest < ReactComponentTestCase
  test "works with basic data" do
    skip
    track = create :track
    solution = create(:practice_solution, track:)

    data = {
      default_submissions: [],
      default_files: SerializeEditorFiles.(solution.files_for_editor),
      premium: false,
      chatgpt_usage: {},
      default_settings: {
        tab_size: track.indent_size,
        use_soft_tabs: track.indent_style == :space
      },
      autosave: {
        key: solution.uuid,
        save_interval: 500
      },
      panels: {
        instructions: {
          introduction:,
          assignment: SerializeExerciseAssignment.(solution),
          debugging_instructions:
        },
        tests: {
          test_files: SerializeFiles.(solution.test_files),
          highlightjs_language: track.highlightjs_language
        },
        results: {
          test_runner: {
            average_test_duration: track.average_test_duration
          }
        },
        ai_help: submission.present? ? SerializeSubmissionAIHelpRecord.(submission.ai_help_records.last) : nil,
        chatgpt_usage:
      },
      iteration: iteration ? {
        analyzer_feedback: iteration&.analyzer_feedback,
        representer_feedback: iteration&.representer_feedback
      } : nil,
      discussion: discussion ? SerializeMentorDiscussionForStudent.(discussion) : nil,
      track: {
        title: track.title,
        slug: track.slug,
        icon_url: track.icon_url
      },
      exercise: {
        title: solution.exercise.title,
        slug: solution.exercise.slug
      },
      mentoring_requested: solution.mentoring_requested?,
      links: links_for(solution)
    }

    component = ReactComponents::Editor.new(solution).to_s
    assert_component component, "editor", { graph: data }
  end

  test "no tests for concept exercises" do
    track = create :track
    solution = create(:practice_solution, track:)
    actual = ReactComponents::Editor.new(solution).data
    refute_nil actual[:panels][:tests]

    solution = create(:concept_solution, track:)
    actual = ReactComponents::Editor.new(solution).data
    assert_nil actual[:panels][:tests]
  end

  def links_for(solution)
    {
      run_tests: api_solution_submissions_url(solution.uuid),
      back: track_exercise_path(solution.track, solution.exercise),
      automated_feedback_info: doc_path('using', 'feedback/automated'),
      mentor_discussions: track_exercise_mentor_discussions_path(solution.track, solution.exercise),
      mentoring_request: track_exercise_mentor_request_path(solution.track, solution.exercise)
    }
  end
end
