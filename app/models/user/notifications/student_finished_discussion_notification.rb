class User
  module Notifications
    class StudentFinishedDiscussionNotification < Notification
      params :discussion

      def url
        discussion.mentor_url
      end

      def i18n_params
        {
          student_name: student.handle,
          track_title: solution.track.title,
          exercise_title: solution.exercise.title
        }
      end

      def image_type
        :avatar
      end

      def image_url
        student.avatar_url
      end

      def guard_params
        "Discussion##{discussion.id}"
      end

      private
      def student
        solution.user
      end

      def solution
        discussion.solution
      end
    end
  end
end
