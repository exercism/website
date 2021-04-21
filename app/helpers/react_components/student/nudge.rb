module ReactComponents
  module Student
    class Nudge < ReactComponent
      initialize_with :solution

      def to_s
        super("student-nudge", {
          solution: SerializeSolution.(solution),
          track: {
            title: solution.track.title,
            median_wait_time: solution.track.median_wait_time
          },
          discussions: discussions,
          iteration: iteration,
          exercise_type: exercise_type,
          links: links
        })
      end

      private
      def exercise_type
        return "tutorial" if solution.exercise.tutorial?

        solution.exercise.concept_exercise? ? "concept" : "practice"
      end

      def iteration
        SerializeIteration.(solution.iterations.order(id: :desc).last)
      end

      def links
        {
          mentoring_info: "#",
          complete_exercise: Exercism::Routes.complete_api_solution_url(solution.uuid),
          share_mentoring: "https://some.link/we/need/to-decide-on", # TODO
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
            id: discussion.uuid,
            mentor: {
              avatar_url: discussion.mentor.avatar_url,
              handle: discussion.mentor.handle
            },
            student: {
              avatar_url: discussion.student.avatar_url,
              handle: discussion.student.handle
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
