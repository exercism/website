class User
  module Notifications
    class MentorStartedDiscussionNotification < Notification
      params :discussion, :discussion_post

      # TODO
      def url
        "#"
      end

      def i18n_params
        {
          mentor_name: mentor.handle,
          track_title: track.title,
          exercise_title: exercise.title
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
      def track
        exercise.track
      end

      def exercise
        solution.exercise
      end

      def solution
        discussion.solution
      end

      def mentor
        discussion.mentor
      end
    end
  end
end
