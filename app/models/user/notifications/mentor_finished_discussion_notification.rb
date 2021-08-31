class User
  module Notifications
    class MentorFinishedDiscussionNotification < Notification
      params :discussion

      def url
        discussion.student_url
      end

      def i18n_params
        {
          mentor_name: mentor.handle,
          track_title: solution.track.title,
          exercise_title: solution.exercise.title
        }
      end

      def image_type
        :avatar
      end

      def image_url
        mentor.avatar_url
      end

      def guard_params
        "Discussion##{discussion.id}"
      end

      private
      def mentor
        discussion.mentor
      end

      def solution
        discussion.solution
      end
    end
  end
end
