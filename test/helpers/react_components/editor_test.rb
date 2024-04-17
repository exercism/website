require_relative "./react_component_test_case"

class ReactComponents::EditorTest < ReactComponentTestCase
  test "works with basic data" do
    skip
    track = create :track
    solution = create(:practice_solution, track:)

    data = {
      default_submissions: [],
      default_files: SerializeEditorFiles.(solution.files_for_editor),
      insiders: false,
      chatgpt_usage: {},
      default_settings: {
        tab_size: track.indent_size,
        use_soft_tabs: track.indent_style == :space
      },
      autosave: {
        key: solution.uuid,
        save_interval: 500
      },
      help: {
        html: Markdown::Parse.(::Track::GenerateHelp.(track))
      },
      panels: {
        instructions: {
          introduction: Markdown::Parse.(solution.introduction),
          assignment: SerializeExerciseAssignment.(solution),
          debugging_instructions: Markdown::Parse.(track.debugging_instructions)
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
        ai_help: nil,
        chatgpt_usage: {}
      },

      exercise: {
        title: solution.exercise.title,
        slug: solution.exercise.slug,
        deep_dive_youtube_id: nil,
        deep_dive_blurb: nil
      },
      solution: {
        uuid: solution.uuid
      },
      request: nil,
      mentoring_requested: false,
      track_objectives: "",
      links: links_for(solution),
      iteration: nil,
      discussion: nil,
      track: {
        title: track.title,
        slug: track.slug,
        icon_url: track.icon_url
      },
      show_deep_dive_video: false
    }

    component = ReactComponents::Editor.new(solution).to_s
    assert_component component, "editor", { graph: data }
  end

  test "uses latest iteration" do
    solution = create(:practice_solution)
    submission = create(:submission, solution:)
    create(:user_track, user: solution.user, track: solution.track)
    actual = ReactComponents::Editor.new(solution).data
    assert_nil actual[:iteration]

    create(:iteration, submission:)
    actual = ReactComponents::Editor.new(solution.reload).data
    refute_nil actual[:iteration]

    # Create an extra submission without an iteration
    create(:submission, solution:)
    actual = ReactComponents::Editor.new(solution.reload).data
    refute_nil actual[:iteration]
  end

  test "no tests for concept exercises" do
    track = create :track
    solution = create(:practice_solution, track:)
    create(:user_track, user: solution.user, track: solution.track)
    actual = ReactComponents::Editor.new(solution).data

    refute_nil actual[:panels][:tests]

    solution = create(:concept_solution, track:)
    create(:user_track, user: solution.user, track: solution.track)
    actual = ReactComponents::Editor.new(solution).data

    assert_nil actual[:panels][:tests]
  end

  test "no deep_dive_video without video" do
    solution = create(:concept_solution)
    solution.exercise.stubs(deep_dive_youtube_id: nil)
    create(:user_track, user: solution.user, track: solution.track)

    actual = ReactComponents::Editor.new(solution).data

    refute actual[:show_deep_dive_video]
  end

  test "show deep_dive_video if id is present" do
    solution = create(:concept_solution)
    solution.exercise.stubs(deep_dive_youtube_id: SecureRandom.uuid)
    create(:user_track, user: solution.user, track: solution.track)

    actual = ReactComponents::Editor.new(solution).data

    assert actual[:show_deep_dive_video]
  end

  test "hide deep_dive_video not first iteration" do
    solution = create(:concept_solution)
    solution.exercise.stubs(deep_dive_youtube_id: SecureRandom.uuid)
    create(:user_track, user: solution.user, track: solution.track)
    create(:iteration, solution:)

    actual = ReactComponents::Editor.new(solution).data
    refute actual[:show_deep_dive_video]
  end

  test "hide deep_dive_video if viewed" do
    youtube_id = SecureRandom.uuid

    solution = create(:concept_solution)
    solution.exercise.stubs(deep_dive_youtube_id: youtube_id)
    create(:user_track, user: solution.user, track: solution.track)
    create :user_watched_video, user: solution.user, video_provider: :youtube, video_id: youtube_id

    actual = ReactComponents::Editor.new(solution).data
    refute actual[:show_deep_dive_video]
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
