class User
  module Notifications
    class MentorRepliedToDiscussionNotification < Notification
      params :discussion_post

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
        "DiscussionPost##{discussion_post.id}"
      end

      private
      def track
        exercise.track
      end

      def exercise
        solution.exercise
      end

      def solution
        discussion_post.solution
      end

      def mentor
        discussion_post.author
      end
    end
  end
end
