module ReactComponents
  class Editor < ReactComponent
    initialize_with :solution
    def to_s
      super("editor", data)
    end

    def data
      {
        default_submissions: submissions,
        default_files: SerializeEditorFiles.(solution.files_for_editor),
        premium: solution.user.premium?,
        chatgpt_usage:,
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
          tests: solution.exercise.practice_exercise? ? {
            test_files: SerializeFiles.(solution.test_files),
            highlightjs_language: track.highlightjs_language
          } : nil,
          results: {
            test_runner: {
              average_test_duration: track.average_test_duration
            }
          },
          ai_help: submission.present? ? SerializeSubmissionAIHelpRecord.(submission.ai_help_records.last) : nil,
          chatgpt_usage:
        },
        exercise: {
          title: solution.exercise.title,
          slug: solution.exercise.slug
        },
        solution: {
          uuid: solution.uuid
        },
        request:,
        mentoring_requested: solution.mentoring_requested?,
        track_objectives: user_track&.objectives.to_s,
        links: {
          run_tests: Exercism::Routes.api_solution_submissions_url(solution.uuid),
          back: Exercism::Routes.track_exercise_path(track, solution.exercise),
          automated_feedback_info: Exercism::Routes.doc_path('using', 'feedback/automated'),
          mentor_discussions: Exercism::Routes.track_exercise_mentor_discussions_path(track, solution.exercise),
          mentoring_request: Exercism::Routes.track_exercise_mentor_request_path(track, solution.exercise),
          create_mentor_request: Exercism::Routes.api_solution_mentor_requests_path(solution.uuid)
        },
        iteration: iteration ? {
          analyzer_feedback: iteration&.analyzer_feedback,
          representer_feedback: iteration&.representer_feedback
        } : nil,
        discussion: discussion ? SerializeMentorDiscussionForStudent.(discussion) : nil,
        track: {
          title: track.title,
          slug: track.slug,
          icon_url: track.icon_url,
          median_wait_time: track.median_wait_time
        }
      }
    end

    # TODO: clean this up, and maybe enough to get the latest iteration?
    def request
      {
        endpoint: Exercism::Routes.latest_api_solution_iterations_path(solution.uuid, sideload: [:automated_feedback]),
        options: {
          initial_data: {
            iteration: latest_iteration
          },
          initial_data_updated_at: Time.current.to_i
        }
      }
    end

    private
    def submissions = submission ? [SerializeSubmission.(submission)] : []

    memoize
    def submission = solution.latest_submission

    memoize
    def iteration = solution.latest_iteration

    memoize
    def latest_iteration = SerializeIteration.(solution.iterations.includes(:track, :exercise, :files, :submission).last,
      sideload: [:automated_feedback])

    memoize
    def discussion = solution.mentor_discussions.last

    memoize
    def introduction
      Markdown::Parse.(solution.introduction)
    end

    memoize
    def chatgpt_usage
      solution.user.chatgpt_usage
    end

    memoize
    def instructions
      Markdown::Parse.(solution.instructions)
    end

    memoize
    def debugging_instructions
      return if track.debugging_instructions.blank?

      Markdown::Parse.(track.debugging_instructions)
    end

    memoize
    def user_track
      UserTrack.for(student, track)
    end

    memoize
    def track
      solution.track
    end
  end
end
