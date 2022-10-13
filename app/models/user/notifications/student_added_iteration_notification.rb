class User
  module Notifications
    class StudentAddedIterationNotification < Notification
      params :discussion, :iteration

      def url = discussion.mentor_url

      def i18n_params
        {
          student_name: student.handle,
          iteration_idx: iteration.idx,
          track_title: track.title,
          exercise_title: exercise.title
        }
      end

      def image_type = :avatar

      def image_url
        student.avatar_url
      end

      def guard_params = "Discussion##{discussion.id}|Iteration##{iteration.id}"

      private
      def track
        iteration.solution.track
      end

      def exercise
        iteration.solution.exercise
      end

      def student
        discussion.student
      end
    end
  end
end
