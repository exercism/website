module ReactComponents
  module Student
    class SolutionSummary < ReactComponent
      initialize_with :solution

      def to_s
        super("student-solution-summary", {
          solution: SerializeSolution.(solution),
          track: {
            title: solution.track.title,
            median_wait_time: solution.track.median_wait_time
          },
          request:,
          discussions:,
          exercise: {
            title: solution.exercise.title,
            type: exercise_type
          },
          links:
        })
      end

      private
      def exercise_type
        return "tutorial" if solution.exercise.tutorial?

        solution.exercise.concept_exercise? ? "concept" : "practice"
      end

      def request
        {
          endpoint: Exercism::Routes.api_solution_url(solution.uuid, sideload: [:iterations]),
          options: {
            initialData: {
              iterations: SerializeIterations.(solution.iterations)
            }
          }
        }
      end

      def links
        {
          tests_pass_locally_article: Exercism::Routes.doc_path(:using, "solving-exercises/tests-pass-locally"),
          all_iterations: Exercism::Routes.track_exercise_iterations_path(solution.track, solution.exercise),
          community_solutions: Exercism::Routes.track_exercise_solutions_path(solution.track, solution.exercise),
          learn_more_about_mentoring_article: Exercism::Routes.doc_path(:using, "feedback"),
          mentoring_info: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored"),
          complete_exercise: Exercism::Routes.complete_api_solution_url(solution.uuid),
          share_mentoring: solution.external_mentoring_request_url,
          request_mentoring: Exercism::Routes.new_track_exercise_mentor_request_path(solution.track, solution.exercise),
          pending_mentor_request: Exercism::Routes.track_exercise_mentor_request_path(solution.track, solution.exercise)
        }.tap do |links|
          in_progress_discussion = solution.mentor_discussions.in_progress_for_student.first
          if in_progress_discussion
            links[:in_progress_discussion] =
              Exercism::Routes.track_exercise_mentor_discussion_path(
                solution.track,
                solution.exercise,
                in_progress_discussion
              )
          end
        end
      end

      def discussions
        solution.mentor_discussions.map do |discussion|
          {
            uuid: discussion.uuid,
            mentor: {
              avatar_url: discussion.mentor.avatar_url,
              handle: discussion.mentor.handle
            },
            student: {
              avatar_url: discussion.student_avatar_url,
              handle: discussion.student_handle
            },
            is_finished: discussion.finished_for_student?,
            is_unread: discussion.posts.where(seen_by_student: false).exists?,
            posts_count: discussion.posts.count,
            created_at: discussion.created_at.iso8601,
            links: {
              self: Exercism::Routes.track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
            }
          }
        end
      end
    end
  end
end
